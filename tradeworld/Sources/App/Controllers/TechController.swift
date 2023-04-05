import Vapor
import Fluent

func techController(tech: RoutesBuilder) {
    tech.get { req async throws -> View in
        return try await req.view.render("tech")
    }
    
    tech.get("unresearched") { req async throws -> [Tech] in
        return try getAvailableTechs(req: req).convertToTechs(req)
    }
    
    tech.get("researchable", ":id") { req async throws -> Bool in
        guard let id = Int(req.parameters.get("id") ?? "nope") else {
            throw Abort(.badRequest)
        }
        // Add tech id to user's array of ints (User.techs)
        let user = try req.auth.require(User.self)
        guard let techs: [Tech] = decodeFile(req: req, "techs", [Tech].self) else {
            throw Abort(.internalServerError)
        }
        guard let tech: Tech = techs[safe: id] else {
            throw Abort(.notFound)
        }
        guard try getAvailableTechs(req: req).contains(id) else {
            return false
        }
        for price in tech.price {
            guard let resources = try await user.$resources.get(on: req.db) else {
                throw Abort(.internalServerError)
            }
            let resource = resources[price.name]
            guard resource >= price.count else {
                return false
            }
        }
        return true
    }
    
    tech.post("research", ":id") { req async throws -> Bool in
        guard let id = Int(req.parameters.get("id") ?? "nope") else {
            throw Abort(.badRequest)
        }
        // Add tech id to user's array of ints (User.techs)
        let user = try req.auth.require(User.self)
        guard let techs: [Tech] = decodeFile(req: req, "techs", [Tech].self) else {
            throw Abort(.internalServerError)
        }
        guard let tech: Tech = techs[safe: id] else {
            throw Abort(.notFound)
        }
        for price in tech.price {
            guard let resources = try await user.$resources.get(on: req.db) else {
                throw Abort(.internalServerError)
            }
            let resource = resources[price.name]
            guard resource >= price.count else {
                throw Abort(.notAcceptable)
            }
            resources[price.name] -= price.count
            try await resources.save(on: req.db)
        }
        user.techs.append(id)
        
        try await user.save(on: req.db)
        return true
    }
    
    func getAvailableTechs(req: Request) throws -> [Int] {
        let user = try req.auth.require(User.self)
        // Only ints that are in defaults but not in user.techs
        var techs: [Int] = []
        guard let techData = decodeFile(req: req, "techs", [Tech].self) else {
            throw Abort(.internalServerError)
        }
        // Iterate through user.techs and add all techs that are in that tech's "techUnlocks" array but not in user.techs
        for tech in user.techs {
            for techUnlock in techData[tech].techUnlocks {
                if !user.techs.contains(techUnlock) {
                    techs.append(techUnlock)
                }
            }
        }
        return techs
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Array where Element == Int {
    func convertToTechs(_ req: Request) throws -> [Tech] {
        guard let techs: [Tech] = decodeFile(req: req, "techs", [Tech].self) else {
            throw Abort(.internalServerError)
        }
        var convertedTechs: [Tech] = []
        for tech in self {
            convertedTechs.append(techs[tech])
        }
        return convertedTechs
    }
}

