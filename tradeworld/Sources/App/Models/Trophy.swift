import Vapor
import Fluent
import JSONValueRX

final class Trophy: Model, Content {
    static let schema: String = "trophy"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "trophy_id")
    var trophyID: Int

    @Field(key: "data")
    var data: JSONValue
    
    @Field(key: "tier")
    var tier: Int

    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "award_date")
    var date: Date

    init() { }

    init(id: UUID? = nil, trophyID: Int, data: JSONValue, tier: Int = 1, userID: User.IDValue, date: Date = Date.now) {
        self.id = id
        self.trophyID = trophyID
        self.data = data
        self.tier = tier
        self.$user.id = userID
        self.date = date
    }
}

struct TrophyData: Content {
    let name: String
    let description: String
    let image: String
}
