import Vapor

func buildingController(building: RoutesBuilder) {
    building.get { req async throws -> [BuildingResponse] in
        guard let buildings = decodeFile(req: req, "buildings", [BuildingResponse].self) else {
            throw Abort(.internalServerError)
        }
        return buildings
    }
    building.post("build") { req async throws -> HTTPStatus in
        // Get post body
        let _ = try req.content.decode(BuildingRequest.self)
        return .ok
    }
    building.post("destroy") { req async throws -> HTTPStatus in
        let _ = try req.content.decode(BuildingRequest.self)
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

func decodeFile<T: Decodable>(req: Request, _ file: String, _ type: T.Type) -> T? {
    let urlString = req.application.directory.resourcesDirectory + "json/\(file).json"
    print(urlString)
    // Read in data at urlString
    guard
        let data = FileManager.default.contents(atPath: urlString),
        let resource = try? JSONDecoder().decode(type, from: data)
    else {
        print("Data not decodable")
        return nil
    }
    return resource
}
