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

    @Parent(key: "user_id")
    var user: User

    init() { }

    init(id: UUID? = nil, trophyID: Int, data: JSONValue, userID: User.IDValue) {
        self.id = id
        self.trophyID = trophyID
        self.data = data
        self.$user.id = userID
    }
}