import Vapor

struct UserResponse: Content {
    let username: String
    let score: Int
    let lastOnline: Date

    init(_ user: User) {
        self.username = user.username
        self.score = user.score
        self.lastOnline = user.visited
    }
}