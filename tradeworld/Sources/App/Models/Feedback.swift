import Vapor
import Fluent

//final class Feedback: Model, Content, Votable {
//    
//
//    init() { }
//    
//    static let schema: String = "feedback"
//    
//    @ID(key: .id)
//    var id: UUID?
//    
//    @Field(key: "title")
//    var title: String
//    
//    @Field(key: "body")
//    var body: String
//
//    @Parent(key: "author_id")
//    var author: User
//
//    @Timestamp(key: "created_at", on: .create)
//    var createdAt: Date?
//
//    @Children(for: \.$feedback)
//    var votes: [Vote]
//
//    init(id: UUID? = nil, title: String, body: String, authorId: UUID) {
//        self.id = id
//        self.title = title
//        self.body = body
//        self.$author.id = authorId
//    }
//}
