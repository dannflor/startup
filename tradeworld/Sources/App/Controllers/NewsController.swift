import Vapor

func newsController(news: RoutesBuilder) {
    let adminProtected = news.grouped(AdminMiddleware())
    adminProtected.group("admin", configure: adminProtectedController)
    
    news.get { req async throws -> View in
        struct NewsResponse: Content {
            let title: String
            let body: String
            let date: String
            
            init(post: NewsPost) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, yyyy"
                self.title = post.title
                self.body = post.body
                self.date = dateFormatter.string(from: post.timestamp)
            }
        }
        let newsPosts = try await NewsPost.query(on: req.db).all().map { NewsResponse(post: $0) }
        return try await req.view.render("news", ["news": newsPosts])
    }

    func adminProtectedController(adminProtected: RoutesBuilder) {
        adminProtected.post { req async throws -> HTTPStatus in
            struct NewsRequest: Content {
                let title: String
                let body: String
            }
            let newsRequest = try req.content.decode(NewsRequest.self)
            let newsPost = NewsPost(title: newsRequest.title, body: newsRequest.body)
            try await newsPost.save(on: req.db)
            return .ok
        }
    }
}
