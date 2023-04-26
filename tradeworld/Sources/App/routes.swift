import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    app.get { req in
        if req.auth.has(User.self) {
            #if DEBUG
            return req.redirect(to: "/game")
            #endif
            return req.redirect(to: "https://tradeworldgame.com/game")
        }
        else {
            #if DEBUG
            return req.redirect(to: "/login")
            #endif
            return req.redirect(to: "https://tradeworldgame.com/login")
        }
        
    }
    
    let loginProtected = app.grouped(User.redirectMiddlewareAsync(path: "/login"))
    let adminProtected = app.grouped(AdminMiddleware())
    
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
        user.techs = [ 25 ]
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
    
    loginProtected.get("score") { req async throws -> Int in
        try await req.auth.require(User.self).getScore(req)
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
    
    loginProtected.get("view") { req async throws in
        try await req.view.render("view")
    }
    
    loginProtected.get("grid", ":user") { req async throws -> [BuildingResponse] in
        guard
            let user = try await User.query(on: req.db).filter(\.$username == req.parameters.get("user") ?? "").first(),
            let layout = try await user.$layout.get(on: req.db)?.layout,
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
        let resource = try await Resource.compute(req)
        return [
            ResourceQty(name: .Wood, count: resource.wood),
            ResourceQty(name: .Stone, count: resource.stone),
            ResourceQty(name: .Gold, count: resource.gold),
            ResourceQty(name: .Iron, count: resource.iron),
            ResourceQty(name: .Food, count: resource.food)
        ]
    }
    
    loginProtected.get("resources", "yields") { req async throws -> [ResourceQty] in
        return try await Resource.getYields(req)
    }
    
    loginProtected.group("building", configure: buildingController)
    loginProtected.group("user", configure: userController)
    loginProtected.group("tech", configure: techController)
    loginProtected.group("trade", configure: tradeController)
    loginProtected.group("mission", configure: missionController)
    loginProtected.group("news", configure: newsController)
    loginProtected.group("leaderboard", configure: leaderboardController)
    loginProtected.group("feedback", configure: feedbackController)
    adminProtected.group("trophy", configure: trophyController)
}

extension String {
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
}

func decodeFile<T: Decodable>(req: Request, _ file: String, _ type: T.Type) -> T? {
    let urlString = req.application.directory.resourcesDirectory + "json/\(file).json"
    // Read in data at urlString
    guard let data = FileManager.default.contents(atPath: urlString) else {
        print("File not found")
        return nil
    }
    guard let resource = try? JSONDecoder().decode(type, from: data) else {
        print("Data not decodable at \(file)")
        return nil
    }
    return resource
}

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}
