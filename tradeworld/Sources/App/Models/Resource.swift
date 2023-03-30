import Fluent
import Vapor

final class Resource: Model, Content {
    init() { }
    
    static let schema: String = "resource"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "wood")
    var wood: Int

    @Field(key: "stone")
    var stone: Int
    
    @Field(key: "gold")
    var gold: Int
    
    @Field(key: "iron")
    var iron: Int
    
    @Field(key: "food")
    var food: Int
    
    @Parent(key: "user_id")
    var user: User
    
    init(id: UUID? = nil, wood: Int, stone: Int, gold: Int, iron: Int, food: Int, userId: UUID) {
        self.id = id
        self.wood = wood
        self.stone = stone
        self.gold = gold
        self.iron = iron
        self.food = food
        self.$user.id = userId
    }

    public subscript(_ resource: ResourceType) -> Int {
        get {
            switch resource {
            case .Wood:
                return wood
            case .Stone:
                return stone
            case .Gold:
                return gold
            case .Iron:
                return iron
            case .Food:
                return food
            }
        }
        set {
            switch resource {
            case .Wood:
                wood = newValue
            case .Stone:
                stone = newValue
            case .Gold:
                gold = newValue
            case .Iron:
                iron = newValue
            case .Food:
                food = newValue
            }
        }
    }
}

enum ResourceType: String, Codable {
    case Wood, Stone, Gold, Iron, Food
}

struct ResourceQty: Content {
    let name: ResourceType
    let count: Int
}
