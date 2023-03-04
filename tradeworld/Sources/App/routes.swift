import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        req.redirect(to: "/login")
    }
    
    app.get("login") { req async throws in
        try await req.view.render("login")
    }
    
    app.post("register") { req async throws in
        let register = try req.content.decode(AuthRequest.self)
        let user = try User(register)
        try await user.create(on: req.db)
//        req.session.data["username"] = user.username
        return req.redirect(to: "/game")
    }
    
    app.post("login") { req async throws in
        let login = try req.content.decode(AuthRequest.self)
        guard let user = try await User.query(on: req.db).filter(\.$username == login.username).first() else {
            throw Abort(.notFound)
        }
//        req.session.data["username"] = user.username
        guard try Bcrypt.verify(login.password, created: user.password) else {
            throw Abort(.badRequest)
        }
        return req.redirect(to: "/game")
    }
    
    app.get("logout") { req async throws in
        try await req.view.render("logout")
    }
    
    app.get("game") { req async throws -> View in
        let resources: [ResourceQty] = [
            ResourceQty(name: .Wood, count: 27),
            ResourceQty(name: .Stone, count: 21),
            ResourceQty(name: .Gold, count: 7),
            ResourceQty(name: .Iron, count: 15),
            ResourceQty(name: .Food, count: 50)
        ]
        let grid: [Building] = []
//        let dummyUser: User = User(username: "someUser", password: "doesntmatter")
//        return try await req.view.render("game", GridContext(grid: grid, resources: resources, user: dummyUser))
        return try await req.view.render("game", GridContext(grid: grid, resources: resources))
    }
    
    app.get("grid") { req async throws -> [Building] in
        var grid: [Building] = []
        
        
        for _ in 0..<49 {
            let num = Int.random(in: 0...10)
            switch num {
            case 0:
                grid.append(Building(name: "Small House", cost: [], img: "/img/sprite_house01.png"))
            case 1:
                grid.append(Building(name: "Medium House", cost: [], img: "/img/sprite_house02.png"))
            case 2:
                grid.append(Building(name: "Big House", cost: [], img: "/img/sprite_house03.png"))
            case 3:
                grid.append(Building(name: "Pasture", cost: [], img: "/img/sprite_pasture.png"))
            case 4:
                grid.append(Building(name: "Tower", cost: [], img: "/img/sprite_tower.png"))
            case 5:
                grid.append(Building(name: "Trees", cost: [], img: "/img/sprite_forest.png"))
            default:
                grid.append(Building(name: "", cost: [], img: "/img/noHouse.png"))
            }
        }
        
        return grid
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
                    message: "Message from seller Message from seller Message from seller Message from sellerMessage from seller Message from seller Message from seller \(element)",
                    offer: ResourceQty(name: .Wood, count: 10),
                    ask: ResourceQty(name: .Gold, count: 1)
                )
            trades.append(trade)
        }
        return try await req.view.render("trade", TradeContext(trades: trades))
    }
    
    try app.register(collection: TodoController())
}
