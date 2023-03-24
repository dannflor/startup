import Fluent
import Vapor

final class Layout: Model, Content {
    static let schema = "layout"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "layout")
    var layout: [Building]
    
    @Parent(key: "user_id")
    var user: User

    init() { }

    init(id: UUID? = nil, layout: [Building], user: UUID) {
        self.id = id
        self.layout = layout
        self.$user.id = user
    }
}

