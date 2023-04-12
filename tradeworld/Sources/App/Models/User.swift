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
    
    @Field(key: "visit_time")
    var visited: Date

    @Field(key: "join_date")
    var createdAt: Date

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
