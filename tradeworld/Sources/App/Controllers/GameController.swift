import Vapor
import Fluent

func gameController(game: RoutesBuilder) {
    game.get { req async throws -> View in
        struct PopupResponse: Encodable {
            let showPopup: Bool
            let name: String
            let title: String
            let content: String
        }
        guard let config = decodeFile(req: req, "config", Config.self) else {
            throw Abort(.internalServerError, reason: "Couldn't decode configuration file")
        }
        
        return try await req.view.render("game", [
            "popup" : PopupResponse(showPopup: config.showPopup, name: config.popup.name, title: config.popup.title, content: config.popup.content)
        ])
    }
    
}
