import Vapor

struct BuildingMetadata: Content {
    let yield: [ResourceQty]
    let bonus: [String: [ResourceQty]]
    let bonusDescription: String
    let score: Int
}
