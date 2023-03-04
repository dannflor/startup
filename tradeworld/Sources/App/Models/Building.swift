import Vapor

struct Building: Content {
    let name: String
    let resource: Bool
    let cost: [ResourceQty]
    
    init(name: String, resource: Bool = false, cost: [ResourceQty]) {
        self.name = name
        self.resource = resource
        self.cost = cost
    }
}
