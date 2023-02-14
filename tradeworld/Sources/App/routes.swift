import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        req.redirect(to: "/login")
    }
    
    app.get("login") { req async throws in
        try await req.view.render("login")
    }
    
    app.get("game") { req async throws -> View in
        let grid = Array(1...49)
        return try await req.view.render("game", GridContext(grid: grid))
    }
    
    app.get("tech") { req async throws -> View in
        var techs: [Tech] = []
        let arr = Array(1...10)
        for element in arr {
            let tech =
                Tech(
                    id: element,
                    title: "Tech Number \(element)",
                    description: "Description for tech number \(element)",
                    price: element*10
                )
            techs.append(tech)
        }
        return try await req.view.render("tech", TechContext(techs: techs))
    }
    
    app.get("trade") { req async throws -> View in
        var trades: [Trade] = []
        let arr = Array(1...10)
        for element in arr {
            let trade =
                Trade(
                    id: element,
                    seller: "Seller ID \(element)",
                    message: "Message from seller \(element)",
                    offer: Resource(id: 10, name: "Wood", count: 10),
                    ask: Resource(id: 11, name: "Gold", count: 1)
                )
            trades.append(trade)
        }
        return try await req.view.render("trade", TradeContext(trades: trades))
    }
    
    try app.register(collection: TodoController())
}
