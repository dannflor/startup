import Vapor

struct BuildingResponse: Content {
    let name: String
    let terrain: Terrain
    let cost: [ResourceQty]
    
    init(name: String, terrain: Terrain = .none, cost: [ResourceQty]) {
        self.name = name
        self.terrain = terrain
        self.cost = cost
    }
}
