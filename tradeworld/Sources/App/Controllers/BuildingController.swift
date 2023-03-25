import Vapor
import Fluent

func buildingController(building: RoutesBuilder) {
    building.get { req async throws -> [BuildingResponse] in
        guard let buildings = decodeFile(req: req, "buildings", [BuildingResponse].self) else {
            throw Abort(.internalServerError)
        }
        return buildings
    }
    building.get("metadata") { req async throws -> [String: BuildingMetadata] in
        guard let metadata = decodeFile(req: req, "buildingMetadata", [String: BuildingMetadata].self) else {
            throw Abort(.internalServerError)
        }
        return metadata
//        return [
//            "Academy": BuildingMetadata(yield: [
//                ResourceQty(name: .Gold, count: 5)
//            ],
//                                        bonus: [
//                                            "Academy": ResourceQty(name: .Gold, count: 5),
//                                            "University": ResourceQty(name: .Gold, count: 5),
//                                        ],
//                                        bonusDescription: "Nearby military and educational buildings produce more gold",
//                                        score: 6)
//        ]
        
    }
    building.post("build") { req async throws -> HTTPStatus in
        // Get post body
        let request = try req.content.decode(BuildingRequest.self)
        guard let building = Building(rawValue: request.buildingName) else {
            throw Abort(.badRequest)
        }
        guard var layout = try await req.auth.require(User.self).$layout.get(on: req.db) else {
            throw Abort(.internalServerError)
        }
        layout.layout[request.index] = building
        try await layout.save(on: req.db)
        return .ok
    }
    building.post("destroy") { req async throws -> HTTPStatus in
        let request = try req.content.decode(BuildingRequest.self)
        guard var layout = try await req.auth.require(User.self).$layout.get(on: req.db) else {
            throw Abort(.internalServerError)
        }
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
    }
}


