import Vapor
import Fluent
protocol Votable: Model {
    var id: UUID? { get set }
    var votes: [User] { get set }
}

//final class Vote: Model {
//    static let schema: String = "vote"
//    
//    @ID(key: .id)
//    var id: UUID?
//    
//    @Parent(key: "user_id")
//    var user: User
//    
//    @Parent(key: "votable_id")
//    var votable: some Votable
//    
//    @Field(key: "votable_type")
//    var votableType: String
//    
//    init() { }
//    
//    init(id: UUID? = nil, userId: UUID, votableId: UUID, votableType: String) {
//        self.id = id
//        self.$user.id = userId
//        self.$votable.id = votableId
//        self.votableType = votableType
//    }
//}
