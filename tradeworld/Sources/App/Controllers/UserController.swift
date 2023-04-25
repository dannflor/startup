import Vapor
import CoreFoundation
import Fluent

func userController(user: RoutesBuilder) {
    user.get { req async throws -> [UserResponse] in
        let users = try await User.query(on: req.db).all()
        let userResponses = users.map { UserResponse($0) }
        return userResponses
    }
    user.get("me") { req throws -> String in
        try req.auth.require(User.self).username
    }
    user.get("active") { req async throws -> Int in
        // Return every user active in the last hour
        try await User.query(on: req.db).filter(\.$visited > Date.now - 3600).all().count
    }
    user.get("active", "all") { req async throws -> [String] in
        // Return every user active in the last hour
        try await User.query(on: req.db).filter(\.$visited > Date.now - 3600).all().map {
            $0.username
        }
    }
    user.group(":name") { name in
        name.get { req async throws -> UserResponse in
            guard let username = req.parameters.get("name") else {
                throw Abort(.badRequest)
            }
            guard let user = try await User.query(on: req.db).filter(\.$username == username).first() else {
                throw Abort(.notFound)
            }
            return UserResponse(user)
        }
        name.get("resources") { req async throws -> [ResourceQty] in
            guard let username = req.parameters.get("name") else {
                throw Abort(.badRequest)
            }
            guard let user = try await User.query(on: req.db).filter(\.$username == username).first() else {
                throw Abort(.notFound)
            }
            let resource = try await Resource.compute(req, user: user)
            return [
                ResourceQty(name: .Wood, count: resource.wood),
                ResourceQty(name: .Stone, count: resource.stone),
                ResourceQty(name: .Gold, count: resource.gold),
                ResourceQty(name: .Iron, count: resource.iron),
                ResourceQty(name: .Food, count: resource.food)
            ]
        }
        name.get("resources", "yields") { req async throws -> [ResourceQty] in
            guard let username = req.parameters.get("name") else {
                throw Abort(.badRequest)
            }
            guard let user = try await User.query(on: req.db).filter(\.$username == username).first() else {
                throw Abort(.notFound)
            }
            return try await Resource.getYields(req, user: user)
        }
        
    }
}
