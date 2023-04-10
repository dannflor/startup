import Vapor
import Fluent
import FluentSQL

final class MissionTransaction: Model, Content {
    init() { }
    
    static let schema: String = "mission_transaction"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "contrib_id")
    var contributor: User

    @Field(key: "created_at")
    var createdAt: Date
    
    @Field(key: "contrib_amount")
    var contribAmount: Int
    
    @Field(key: "contrib_resource")
    var contribResource: ResourceType
    
    init(id: UUID? = nil, contributor: UUID,
         createdAt: Date = Date.now, contribAmount: Int,
         contribResource: ResourceType) {
        self.id = id
        self.$contributor.id = contributor
        self.createdAt = createdAt
        self.contribAmount = contribAmount
        self.contribResource = contribResource
    }
    
    static func getTotal(db: Database, res: ResourceType) async throws -> Int {
        return try await db.query(MissionTransaction.self)
            .filter(\.$contribResource == res)
            .all()
            .reduce(0) { $0 + $1.contribAmount }
    }
    static func getTotals(req: Request) async throws -> [ResourceQty] {
        var totals: [ResourceQty] = []
        guard let mission = Mission.current(req: req) else {
            return []
        }
        for requirement in mission.requirements {
            try await totals.append(ResourceQty(name: requirement.name, count: getTotal(db: req.db, res: requirement.name)))
        }
        return totals
    }

    static func getTopFive(req: Request) async throws -> [MissionScore] {
        guard let mission = Mission.current(req: req) else {
            return []
        }
        let contributions = try await MissionTransaction.query(on: req.db)
            .all()
        // Group by user
        var groupedContributions: [UUID: [MissionTransaction]] = [:]
        for contribution in contributions {
            if groupedContributions[contribution.$contributor.id] == nil {
                groupedContributions[contribution.$contributor.id] = []
            }
            groupedContributions[contribution.$contributor.id]?.append(contribution)
        }
        // Calculate score
        var scores: [MissionScore] = []
        for (contributor, contributions) in groupedContributions {
            var score: [ResourceQty] = []
            for requirement in mission.requirements {
                let count = contributions.filter { $0.contribResource == requirement.name }.reduce(0) { $0 + $1.contribAmount }
                score.append(ResourceQty(name: requirement.name, count: count))
            }
            if let user = try await User.find(contributor, on: req.db) {
                scores.append(MissionScore(username: user.username, score: score))
            }
        }
        // Sort by score
        scores.sort { $0.score.reduce(0) { $0 + $1.count } > $1.score.reduce(0) { $0 + $1.count } }
        // Return top 5
        return Array(scores.prefix(5))
    }
}

struct MissionScore: Content {
    var username: String
    var score: [ResourceQty]
}
