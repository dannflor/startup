import Vapor
import Fluent

func buildingController(building: RoutesBuilder) {
    building.get { req async throws -> [BuildingResponse] in
        guard let buildings = decodeFile(req: req, "buildings", [BuildingResponse].self) else {
            throw Abort(.internalServerError)
        }
        let techs = try Tech.lookup(req)
        let buildingNames = techs.reduce([]) { addedTechs, tech in
            addedTechs + tech.buildingUnlocks.reduce([]) { addedBuildings, buildingName in
                addedBuildings + [buildingName]
            }
        }
        var response: [BuildingResponse] = []
        // get building responses that have a name property matching a Building.rawValue in buildingNames
        for building in buildings {
            if buildingNames.contains(.init(rawValue: building.name) ?? .NoHouse) {
                response.append(building)
            }
        }
        return response
    }
    building.get(":name") { req async throws -> BuildingResponse in
        guard let name = req.parameters.get("name") else {
            throw Abort(.badRequest)
        }
        guard let buildings = decodeFile(req: req, "buildings", [BuildingResponse].self) else {
            throw Abort(.internalServerError)
        }
        for building in buildings {
            if building.name == name {
                return building
            }
        }
        throw Abort(.notFound)
    }
    building.get("yield", ":index") { req async throws -> [ResourceQty] in
        struct YieldQuery: Content {
            let name: String?
        }
        let query = try req.query.decode(YieldQuery.self)
        let index = try req.parameters.require("index", as: Int.self)
        var user = try req.auth.require(User.self)
        if
            let name = query.name,
            let viewUser = try await User.query(on: req.db).filter(\.$username == name).first() {
                user = viewUser
        }
        guard let layout = try await user.$layout.get(on: req.db)?.layout else {
            throw Abort(.internalServerError)
        }
        let neighborsOpt = Building.getNeighbors(index)
        var neighbors: [Int] = []
        if let first = neighborsOpt.0 {
            neighbors.append(first)
        }
        if let second = neighborsOpt.1 {
            neighbors.append(second)
        }
        if let third = neighborsOpt.2 {
            neighbors.append(third)
        }
        if let fourth = neighborsOpt.3 {
            neighbors.append(fourth)
        }
        let neighborsBuildings = neighbors.map { layout[$0] }
        let yield = layout[index].yield(neighbors: neighborsBuildings, techs: try Tech.lookup(req), req: req)
        return yield
    }
    building.post("build") { req async throws -> Bool in
        // Get post body
        let request = try req.content.decode(BuildingRequest.self)
        let waterNeighbors = [26, 32, 37, 41, 44, 46]
        guard let building = Building(rawValue: request.buildingName) else {
            throw Abort(.badRequest)
        }
        if building == .Watermill || building == .Fishery {
            guard waterNeighbors.contains(request.index) else {
                throw Abort(.badRequest)
            }
        }
        guard let layout = try await req.auth.require(User.self).$layout.get(on: req.db) else {
            throw Abort(.internalServerError)
        }
        guard let buildings = decodeFile(req: req, "buildings", [BuildingResponse].self) else {
            throw Abort(.internalServerError)
        }
        guard let resources = try await req.auth.require(User.self).$resources.get(on: req.db) else {
            throw Abort(.internalServerError)
        }
        for b in buildings {
            if b.name == request.buildingName {
                for cost in b.cost {
                    if resources[cost.name] < cost.count {
                        return false
                    }
                    resources[cost.name] -= cost.count
                }
            }
        }
        try await resources.save(on: req.db)
        layout.layout[request.index] = building
        try await layout.save(on: req.db)
        return true
    }
    building.post("destroy") { req async throws -> HTTPStatus in
        let request = try req.content.decode(BuildingRequest.self)
        let waterNeighbors = [26, 32, 37, 41, 44, 46]
        guard let building = Building(rawValue: request.buildingName) else {
            throw Abort(.badRequest)
        }
        if building == .Watermill || building == .Fishery {
            guard waterNeighbors.contains(request.index) else {
                throw Abort(.badRequest)
            }
        }
        guard let layout = try await req.auth.require(User.self).$layout.get(on: req.db) else {
            throw Abort(.internalServerError)
        }
        guard let buildings = decodeFile(req: req, "buildings", [BuildingResponse].self) else {
            throw Abort(.internalServerError)
        }
        guard let resources = try await req.auth.require(User.self).$resources.get(on: req.db) else {
            throw Abort(.internalServerError)
        }
        guard layout.layout[request.index] != .NoHouse else {
            throw Abort(.badRequest)
        }
        for b in buildings {
            if b.name == request.buildingName {
                for cost in b.cost {
                    resources[cost.name] += cost.count / 2
                }
            }
        }
        try await resources.save(on: req.db)
        layout.layout[request.index] = .NoHouse
        try await layout.save(on: req.db)
        return .ok
    }
    building.group(":name") { name in
        name.get("cost") { req async throws -> [ResourceQty] in
            guard let name = req.parameters.get("name") else {
                throw Abort(.badRequest)
            }
            guard let buildings = decodeFile(req: req, "buildings", [BuildingResponse].self) else {
                throw Abort(.internalServerError)
            }
            for building in buildings {
                if building.name == name {
                    return building.cost
                }
            }
            throw Abort(.notFound)
        }
        name.get("metadata") { req async throws -> BuildingMetadata in
            guard let name = req.parameters.get("name") else {
                throw Abort(.badRequest)
            }
            guard let metadata = decodeFile(req: req, "buildingMetadata", [String: BuildingMetadata].self) else {
                throw Abort(.internalServerError)
            }
            guard let response = metadata[name] else {
                print("Bad")
                throw Abort(.notFound)
            }
            return response
        }
    }
}


