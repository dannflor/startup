import Vapor
import Fluent

final class User: Model {
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
    
    @Children(for: \.$user)
    var resources: [Resource]
    
    init(id: UUID? = nil, username: String, password: String, score: Int) {
        self.id = id
        self.username = username
        self.password = password
        self.resources = []
        self.score = score
    }
    
    init(_ request: AuthRequest) throws {
        self.username = request.username
        self.password = try Bcrypt.hash(request.password, cost: 8)
        self.score = 0
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$username
    static let passwordHashKey = \User.$password

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}
