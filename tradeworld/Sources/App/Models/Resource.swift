import Fluent
import Vapor

final class Resource: Model {
    init() { }
    
    static let schema: String = "resource"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: ResourceType

    @Field(key: "count")
    var count: Int
    
    @Parent(key: "user_id")
    var user: User
    
    init(id: UUID? = nil, name: ResourceType, count: Int, userId: UUID) {
        self.id = id
        self.name = name
        self.count = count
        self.$user.id = userId
    }
}

enum ResourceType: String, Codable {
    case wood, stone, gold
}

struct ResourceQty: Content {
    let name: ResourceType
    let count: Int
    
    
}
