import Vapor
import Fluent

final class NewsPost: Model, Content {
    static let schema: String = "news_post"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "body")
    var body: String

    @Field(key: "timestamp")
    var timestamp: Date

    init () { }

    init(id: UUID? = nil, title: String, body: String, timestamp: Date = Date.now) {
        self.id = id
        self.title = title
        self.body = body
        self.timestamp = timestamp
    }
}