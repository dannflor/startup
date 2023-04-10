import Vapor
import CoreFoundation
import Fluent

func tradeController(trade: RoutesBuilder) {
    
    trade.get { req async throws -> View in
        let trades = try await TradeTransaction.query(on: req.db).sort(\.$createdAt, .descending).limit(10).all()
        var transactions: [TradeTransactionResponse] = []
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MMM d, h:mm a"
        for trade in trades {
            let seller = try await trade.$seller.get(on: req.db)
            let buyer = try await trade.$buyer.get(on: req.db)
            transactions.append(
                TradeTransactionResponse(
                    seller: seller.username,
                    buyer: buyer.username,
                    date: dateFormat.string(from: trade.createdAt),
                    askResource: trade.askResource.rawValue,
                    askAmount: trade.askAmount,
                    offerResource: trade.offerResource.rawValue,
                    offerAmount: trade.offerAmount
                )
            )
        }
        return try await req.view.render("trade", TradeContext(trades: transactions))
    }

    trade.webSocket("all") { req, ws async in
        req.tradeConnectionManager.client.connect(ws, req)
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


    


