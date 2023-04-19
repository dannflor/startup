import Vapor

struct LeaderboardContext: Encodable {
    let users: [LeaderboardEntry]
    let page: Int
}

struct LeaderboardEntry: Content {
    var username: String
    var score: Int
    var resource: Resource
}
