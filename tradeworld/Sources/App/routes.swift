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
                grid.append(Building(name: "Small House", cost: [ResourceQty(name: .Wood, count: 10), ResourceQty(name: .Stone, count: 5)]))
            case 1:
                grid.append(Building(name: "Medium House", cost: [ResourceQty(name: .Wood, count: 15), ResourceQty(name: .Stone, count: 10)]))
            case 2:
                grid.append(Building(name: "Large House", cost: [ResourceQty(name: .Wood, count: 20), ResourceQty(name: .Stone, count: 15)]))
            case 3:
                grid.append(Building(name: "Pasture", cost: [ResourceQty(name: .Wood, count: 20)]))
            case 4:
                grid.append(Building(name: "Tower", cost: [ResourceQty(name: .Stone, count: 25)]))
            case 5:
                grid.append(Building(name: "Forest", resource: true, cost: []))
            default:
                grid.append(Building(name: "", resource: true, cost: []))
            }
        }
        
        return grid
    }
    
    app.group("building", configure: buildingController)
    
    app.group("user", configure: userController)
    
    app.group("tech", configure: techController)
    
    app.group("trade", configure: tradeController)
}
