import Vapor
import CoreFoundation
import Fluent

func tradeController(trade: RoutesBuilder) {
    trade.get { req async throws -> View in
        return try await req.view.render("trade")
    }
    
    trade.get("all") { req async throws -> [Trade] in
        var trades: [Trade] = []
        let arr = Array(1...10)
        for element in arr {
            let trade =
                Trade(
                    id: element,
                    seller: "Seller ID \(element)",
                    message: "Message from seller Message from seller Message from seller Message from sellerMessage from seller Message from seller Message from seller \(element)",
                    offer: ResourceQty(name: .Wood, count: 10),
                    ask: ResourceQty(name: .Gold, count: 1)
                )
            trades.append(trade)
        }
        return trades
    }
    
    trade.post("accept", ":id") { req async throws -> HTTPStatus in
        guard let _ = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        return .ok
    }
}
