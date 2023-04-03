import Vapor
import CoreFoundation
import Fluent

func userController(user: RoutesBuilder) {
    user.get { req async throws -> [User] in
        let users = try await User.query(on: req.db).all()
        return users
    }
    user.get("me") { req throws -> String in
        try req.auth.require(User.self).username
    }
    user.group(":name") { name in
        name.get { req async throws -> User in
            guard let username = req.parameters.get("name") else {
                throw Abort(.badRequest)
            }
            guard let user = try await User.query(on: req.db).filter(\.$username == username).first() else {
                throw Abort(.notFound)
            }
            return user
        }
    }
}
