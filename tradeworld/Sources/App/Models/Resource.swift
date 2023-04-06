import Fluent
import Vapor

final class Resource: Model, Content {
    init() { }
    
    static let schema: String = "resource"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "wood")
    var wood: Int

    @Field(key: "stone")
    var stone: Int
    
    @Field(key: "gold")
    var gold: Int
    
    @Field(key: "iron")
    var iron: Int
    
    @Field(key: "food")
    var food: Int
    
    @Parent(key: "user_id")
    var user: User
    
    init(id: UUID? = nil, wood: Int, stone: Int, gold: Int, iron: Int, food: Int, userId: UUID) {
        self.id = id
        self.wood = wood
        self.stone = stone
        self.gold = gold
        self.iron = iron
        self.food = food
        self.$user.id = userId
    }

    public subscript(_ resource: ResourceType) -> Int {
        get {
            switch resource {
            case .Wood:
                return wood
            case .Stone:
                return stone
            case .Gold:
                return gold
            case .Iron:
                return iron
            case .Food:
                return food
            }
        }
        set {
            switch resource {
            case .Wood:
                wood = newValue
            case .Stone:
                stone = newValue
            case .Gold:
                gold = newValue
            case .Iron:
                iron = newValue
            case .Food:
                food = newValue
            }
        }
    }
    
    public static func getYields(_ req: Request) async throws -> [ResourceQty] {
        guard let layout = try await req.auth.require(User.self).$layout.get(on: req.db)?.layout else {
            throw Abort(.internalServerError)
        }
        let techs = try Tech.lookup(req)
        
        var yields: [ResourceQty] = [
            ResourceQty(name: .Wood, count: 0),
            ResourceQty(name: .Stone, count: 0),
            ResourceQty(name: .Gold, count: 0),
            ResourceQty(name: .Iron, count: 0),
            ResourceQty(name: .Food, count: 0)
        ]

        for (index, building) in layout.enumerated() {
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

            let yieldPerHour = building.yield(neighbors: neighborsBuildings, techs: techs, req: req)
            yields = yields.add(yieldPerHour)
        }
        return yields
    }
    
    public static func compute(_ req: Request) async throws -> Resource {
        guard let resource = try await req.auth.require(User.self).$resources.get(on: req.db) else {
            throw Abort(.internalServerError)
        }
        let yields = try await getYields(req)
        let timeElapsed = try Date().timeIntervalSince(req.auth.require(User.self).visited) / 3600
        let yield = yields.map { ResourceQty(name: $0.name, count: Int((Double($0.count) * timeElapsed).rounded())) }
        resource.addResources(resources: yield)
        let user = try req.auth.require(User.self)
        user.visited = Date.now
        try await user.save(on: req.db)
        // Put the resource back in the database
        try await resource.save(on: req.db)
        return resource
    }
    
    private func addResources(resources: [ResourceQty]) {
        for resource in resources {
            self[resource.name] += resource.count
        }
    }
}

enum ResourceType: String, Codable {
    case Wood, Stone, Gold, Iron, Food
}

struct ResourceQty: Content {
    let name: ResourceType
    let count: Int
}
