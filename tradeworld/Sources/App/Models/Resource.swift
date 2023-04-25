import Fluent
import Vapor

final class Resource: Model, Content, Comparable {
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
        return try await Resource.getYields(req, user: req.auth.require(User.self))
    }

    public static func getYields(_ req: Request, user: User) async throws -> [ResourceQty] {
        guard let layout = try await user.$layout.get(on: req.db)?.layout else {
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
        return try await compute(req, user: req.auth.require(User.self))
    }

    public static func compute(_ req: Request, user: User) async throws -> Resource {
        guard let resource = try await user.$resources.get(on: req.db) else {
            throw Abort(.internalServerError)
        }
        let yields = try await getYields(req, user: user)
        let timeElapsed = Date().timeIntervalSince(user.visited) / 3600
        let yield = yields.map { ResourceQty(name: $0.name, count: Int((Double($0.count) * timeElapsed).rounded())) }
        resource.addResources(resources: yield)
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

    public static func < (lhs: Resource, rhs: Resource) -> Bool {
        return lhs.wood + lhs.stone + lhs.gold + lhs.iron + lhs.food < rhs.wood + rhs.stone + rhs.gold + rhs.iron + rhs.food
    }

    public static func == (lhs: Resource, rhs: Resource) -> Bool {
        return lhs.wood == rhs.wood && lhs.stone == rhs.stone && lhs.gold == rhs.gold && lhs.iron == rhs.iron && lhs.food == rhs.food
    }
}

enum ResourceType: String, Codable {
    case Wood, Stone, Gold, Iron, Food
}

struct ResourceQty: Content {
    let name: ResourceType
    let count: Int
}

struct ResourceProgress: Content {
    let name: ResourceType
    let current: Int
    let total: Int
    
    static func zipQty(qty1: [ResourceQty], qty2: [ResourceQty]) -> [ResourceProgress] {
        var progress: [ResourceProgress] = []
        for (item1, item2) in zip(qty1, qty2) {
            progress.append(ResourceProgress(name: item1.name, current: item1.count, total: item2.count))
        }
        return progress
    }
}
