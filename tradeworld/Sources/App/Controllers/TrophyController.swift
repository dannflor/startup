import Vapor
import Fluent
import JSONValueRX

func trophyController(trophy: RoutesBuilder) {
    trophy.post { req async throws in
        struct TrophyRequest: Content {
            let username: String
            let trophyID: Int
            let tier: Int
            let data: JSONValue
        }
        let trophyRequest = try req.content.decode(TrophyRequest.self)
        guard let userID = try await User.query(on: req.db).filter(\.$username == trophyRequest.username).first()?.id else {
            throw Abort(.notFound)
        }
        let trophy = Trophy(trophyID: trophyRequest.trophyID, data: trophyRequest.data, tier: trophyRequest.tier, userID: userID)
        try await trophy.save(on: req.db)
        return trophy

    }
}
