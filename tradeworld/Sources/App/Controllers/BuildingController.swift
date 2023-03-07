import Vapor
import CoreFoundation

func buildingController(building: RoutesBuilder) {
    building.get { req async throws -> [Building] in
        guard let buildings = decodeFile("buildings", [Building].self) else {
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
            guard let buildings = decodeFile("buildings", [Building].self) else {
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

func decodeFile<T: Decodable>(_ file: String, _ type: T.Type) -> T? {
    guard
        let url = Bundle.module.url(forResource: "Resources/" + file, withExtension: "json"),
        let data = try? Data(contentsOf: url),
        let resource = try? JSONDecoder().decode(type, from: data)
    else {
        return nil
    }
    return resource
}
