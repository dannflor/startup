import Vapor
import CoreFoundation
import Fluent

func tradeController(trade: RoutesBuilder) {
    trade.get { req async throws -> View in
        return try await req.view.render("trade")
    }

    trade.webSocket("all") { req, ws async in
        do {
            let trades = try await Trade.query(on: req.db).all()
            var tradeResponses: [TradeResponse] = []
            for trade in trades {
                try await tradeResponses.append(TradeResponse(trade, req))
            }
            try await ws.send(String(decoding: JSONEncoder().encode(tradeResponses), as: UTF8.self))
        }
        catch {
            print(error)
        }
        
        ws.onText { ws, text async in
            do {
                try await ws.send(text)
            }
            catch {
                print(error)
            }
        }
    }
    
    trade.post("accept", ":id") { req async throws -> HTTPStatus in
        guard let _ = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        return .ok
    }
    
    trade.post("add") { req async throws -> HTTPStatus in
        let request = try req.content.decode(TradeResponse.self)
        let trade = Trade(id: request.id, seller: request.seller, message: request.message)
        try await trade.create(on: req.db)
        try await trade.$offer.create(Offer(name: request.offer.name, count: request.offer.count, tradeId: trade.requireID()), on: req.db)
        try await trade.$ask.create(Ask(name: request.ask.name, count: request.ask.count, tradeId: trade.requireID()), on: req.db)
        return .ok
    }
}
