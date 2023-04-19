import Vapor
import Fluent

func leaderboardController(leaderboard: RoutesBuilder) {
    
    leaderboard.get {
        return $0.redirect(to: "/leaderboard/1")
    }
    
    leaderboard.get(":page") { req async throws -> View in
        let page = Int(req.parameters.get("page") ?? "1") ?? 1
        let users = try await User.query(on: req.db).all().asyncMap { user in
            try await LeaderboardEntry(username: user.username, score: user.getScore(req), resource: user.$resources.get(on: req.db) ?? Resource())
        }.filter {
            $0.score >= 50
        }.sorted {
            // Sort by score and then by resource
            if ($0.score != $1.score) {
                return $0.score > $1.score
            }
            else {
                return $0.resource > $1.resource
            }
        }
        
        let context = LeaderboardContext(users: users, page: page)
        return try await req.view.render("leaderboard", context)
    }
}
