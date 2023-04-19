import Vapor
import Fluent
import Foundation

final class User: Model, Content, ModelSessionAuthenticatable {
    init() { }
    
    static let schema: String = "user"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "score")
    var score: Int
    
    @Field(key: "techs")
    var techs: [Int]

    @Children(for: \.$user)
    var trophies: [Trophy]
    
    @Field(key: "visit_time")
    var visited: Date

    @Field(key: "join_date")
    var createdAt: Date

    @Field(key: "roles")
    var roles: User.Roles

    // Reference to the user's layout
    @OptionalChild(for: \.$user)
    var layout: Layout?
    
    @OptionalChild(for: \.$user)
    var resources: Resource?
    
    init(id: UUID? = nil, username: String, password: String, score: Int, createdAt: Date = Date.now) {
        self.id = id
        self.username = username
        self.password = password
        self.resources = nil
        self.layout = nil
        self.score = score
        self.visited = Date.now
        self.createdAt = createdAt
    }
    
    init(_ request: AuthRequest) throws {
        self.username = request.username
        self.password = try Bcrypt.hash(request.password, cost: 8)
        self.score = 0
    }

    func getScore(_ req: Request) async throws -> Int {
        var score = 0
        guard let layout = try await self.$layout.get(on: req.db)?.layout else {
            throw Abort(.internalServerError)
        }
        let techs = try Tech.lookup(req)
        score += layout.reduce(score) { addedScore, building in
            addedScore + building.getMetadata(req: req).score
        }
        score += techs.reduce(score) { addedScore, tech in
            addedScore + tech.effects.reduce(0) { effectScore, effect in
                effectScore + effect.score
            }
        }
        return score
    }
}

extension User: SessionAuthenticatable {
    var sessionID: UUID {
        self.id ?? UUID.generateRandom()
    }
}

extension User: ModelCredentialsAuthenticatable {
    static let usernameKey = \User.$username
    static let passwordHashKey = \User.$password

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}

extension User {
    struct Roles: OptionSet, Codable {
        let rawValue: Int64
        static let admin = Self(rawValue: 1 << 32)
        static let verifiedEmail = Self(rawValue: 1)
        static let founder = Self(rawValue: 1 << 1)
    }
}
