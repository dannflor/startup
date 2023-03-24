import Fluent
import Vapor

final class Layout: Model, Content {
    static let schema = "layout"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "layout")
    var layout: [Building]

    init() { }

    init(id: UUID? = nil, title: String) {
        self.id = id
        self.title = title
    }
}

