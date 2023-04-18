import Vapor
import Fluent

final class AdminMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        if request.auth.has(User.self) {
            let user = try request.auth.require(User.self)
            if user.roles.contains(User.Roles.admin) {
                return try await next.respond(to: request)
            }
        }
        throw Abort(.forbidden, reason: "Admins only, fools")

    }
}