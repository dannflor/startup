import Vapor
import Fluent
func missionController(mission: RoutesBuilder) {
    mission.get { req async throws -> View in
        let mission = Mission.current(req: req)
        let totals = try await MissionTransaction.getTotals(req: req)
        return try await req.view.render("mission", MissionContext(
            mission: mission, 
            requirements: ResourceProgress.zipQty(qty1: totals, qty2: mission?.requirements ?? []), 
            topFive: try await MissionTransaction.getTopFive(req: req),
            yourContrib: try await MissionTransaction.getMyTotal(req: req)
        ))
    }
    
    mission.post("contribute", ":resource", ":amount") { req async throws -> Int in
        guard let resource = ResourceType(rawValue: req.parameters.get("resource") ?? "") else {
            throw Abort(.badRequest)
        }
        guard let amount = Int(req.parameters.get("amount") ?? "") else {
            throw Abort(.badRequest)
        }
        guard amount > 0 else {
            throw Abort(.badRequest)
        }
        let user = try req.auth.require(User.self)
        guard let resources = try await user.$resources.get(on: req.db) else {
            throw Abort(.internalServerError)
        }
        guard resources[resource] >= amount else {
            throw Abort(.badRequest)
        }
        resources[resource] -= amount
        try await resources.save(on: req.db)
        let missionTransaction = try MissionTransaction(contributor: user.requireID(), contribAmount: amount, contribResource: resource)
        try await missionTransaction.save(on: req.db)
        return try await MissionTransaction.getTotal(db: req.db, res: resource)
    }
}
