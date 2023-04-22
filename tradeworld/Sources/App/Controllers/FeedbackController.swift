import Vapor
import Fluent

func feedbackController(feedback: RoutesBuilder) {
    feedback.get { req async throws -> View in
        
        try await req.view.render("feedback")
    }
}
