import Vapor
import Fluent

func gridController(grid: RoutesBuilder) {
    grid.get { req async throws -> [BuildingResponse] in
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
    
    grid.get(":user") { req async throws -> [BuildingResponse] in
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

    grid.get("purchase") { req async throws in
        guard let layout = try await req.auth.require(User.self).$layout.get(on: req.db)?.layout else {
            throw Abort(.internalServerError)
        }
        return HTTPResponseStatus.ok

    }
}
