import Vapor

struct AuthRequest: Content {
    var username: String
    var password: String
}
