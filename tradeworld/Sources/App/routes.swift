import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        req.redirect(to: "/login")
    }
    
    let loginProtected = app.grouped(User.redirectMiddlewareAsync(path: "/login"))
    
    app.get("login") { req async throws in
        try await req.view.render("login")
    }
    
    app.post("register") { req async throws in
        let register = try req.content.decode(AuthRequest.self)
        let user = try User(register)
        guard try await User.query(on: req.db).filter(\.$username == register.username).first() == nil else {
            throw Abort(.badRequest, reason: "Username taken")
        }
        guard register.username != "" else {
            throw Abort(.badRequest, reason: "Username is empty")
        }
        guard register.password.count >= 8 else {
            throw Abort(.badRequest, reason: "Password must be at least 8 characters long")
        }
        guard register.username.isAlphanumeric else {
            throw Abort(.badRequest, reason: "Username must only contain letters and numbers")
        }
        try await user.create(on: req.db)
        try await user.$layout.create(createLayout(), on: req.db)
        try await user.$resources.create(createResource(), on: req.db)
        return req.redirect(to: "/game")

        
        func createLayout() throws -> Layout {
            let grid: [Building] = [
                                        .Mountain,
                                    .Mountain, .Mountain,
                                .Mountain, .NoHouse, .Mountain,
                            .Forest, .NoHouse, .NoHouse, .Forest,
                        .Forest, .NoHouse, .NoHouse, .NoHouse, .Forest,
                    .Forest, .NoHouse, .NoHouse, .NoHouse, .NoHouse, .Forest,
                .Forest, .NoHouse, .NoHouse, .NoHouse, .NoHouse, .NoHouse, .Water,
                    .NoHouse, .NoHouse, .NoHouse, .NoHouse, .NoHouse, .Water,
                        .NoHouse, .NoHouse, .NoHouse, .NoHouse, .Water,
                            .NoHouse, .NoHouse, .NoHouse, .Water,
                                .NoHouse, .NoHouse, .Water,
                                    .NoHouse, .Water,
                                        .Water
            ]
            // for _ in 0...48 {
            //     grid.append(Building.terrainTypes.randomElement()!)
            // }
            return Layout(layout: grid, user: try user.requireID())
        }
        func createResource() throws -> Resource {
            Resource(wood: 100, stone: 100, gold: 0, iron: 50, food: 200, userId: try user.requireID())
        }
    }

    app.get("exists", ":user") { req async throws -> Bool in
        guard let user = req.parameters.get("user") else {
            throw Abort(.badRequest)
        }
        guard try await User.query(on: req.db).filter(\.$username == user).first() == nil else {
            return true
        }
        return false
    }
    
    let passwordProtected = app.grouped(User.credentialsAuthenticator())
    
    passwordProtected.post("login") { req async throws in
        let user = try req.auth.require(User.self)
        req.session.data["name"] = user.username
        req.session.data["timestamp"] = "\(Date())"
        req.logger.info("Login: \(user.username)")
        return req.redirect(to: "/game")
        
    }
    
    loginProtected.get("logout") { req async throws -> View in
        req.session.destroy()
        req.auth.logout(User.self)
        return try await req.view.render("logout")
    }
    
    loginProtected.get("game") { req async throws -> View in
        return try await req.view.render("game")
    }
    
    loginProtected.get("score") { req async throws -> Int in
        return Int.random(in: 1...420)
    }
    
    loginProtected.get("grid") { req async throws -> [BuildingResponse] in
        guard
            let layout = try await req.auth.require(User.self).$layout.get(on: req.db)?.layout,
            let mapping = decodeFile(req: req, "buildingNames", [String : BuildingResponse].self)
        else {
            throw Abort(.internalServerError)
        }
        
        let grid = layout.map { elem -> BuildingResponse in
            mapping[elem.rawValue] ?? BuildingResponse(name: "", cost: [])
        }
        
        return grid
    }
    
    loginProtected.get("resources") { req async throws -> [ResourceQty] in
        guard let resource = try await req.auth.require(User.self).$resources.get(on: req.db) else {
            throw Abort(.internalServerError)
        }
        return [
            ResourceQty(name: .Wood, count: resource.wood),
            ResourceQty(name: .Stone, count: resource.stone),
            ResourceQty(name: .Gold, count: resource.gold),
            ResourceQty(name: .Iron, count: resource.iron),
            ResourceQty(name: .Food, count: resource.food)
        ]
        
    }
    
    loginProtected.group("building", configure: buildingController)
    
    loginProtected.group("user", configure: userController)
    
    loginProtected.group("tech", configure: techController)
    
    loginProtected.group("trade", configure: tradeController)
}

extension String {
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
}

func decodeFile<T: Decodable>(req: Request, _ file: String, _ type: T.Type) -> T? {
    let urlString = req.application.directory.resourcesDirectory + "json/\(file).json"
    print(urlString)
    // Read in data at urlString
    guard let data = FileManager.default.contents(atPath: urlString) else {
        print("File not found")
        return nil
    }
    guard let resource = try? JSONDecoder().decode(type, from: data) else {
        print("Data not decodable")
        return nil
    }
    return resource
}
