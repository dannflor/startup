import Vapor
import Fluent

func leaderboardController(leaderboard: RoutesBuilder) {
    
    leaderboard.get {
        return $0.redirect(to: "/leaderboard/1")
    }
    
    leaderboard.get(":page") { req async throws -> View in
        let page = Int(req.parameters.get("page") ?? "1") ?? 1
        let users = try await User.query(on: req.db).all().map { user in
            LeaderboardEntry(username: user.username, score: user.getScore(req), resource: user.$resources.get(on: req.db) ?? Resource())
        }.sorted { 
            // Sort by score and then by resource
            $0.score > $1.score || ($0.score == $1.score && $0.resource > $1.resource)
        }
        
        let context = LeaderboardContext(users: users.items, page: page)
        return try await req.view.render("leaderboard", context)
    }
}
