import Vapor

struct BuildingMetadata: Content {
    let yield: [ResourceQty]
    let yieldBonus: [String: [ResourceQty]]
    let bonusBonus: [String: [ResourceQty]]
    let directionBonus: [String: Int]
    let direction: Direction
    let directionQty: Int
    let bonusDescription: String
    let score: Int
}

enum Direction: String, Content, CaseIterable {
    case SW, SE, NE, NW
}
