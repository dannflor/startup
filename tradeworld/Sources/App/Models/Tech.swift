import Vapor

struct Tech: Content {
    let id: Int
    let title: String
    let description: String
    let price: [ResourceQty]
    let effects: [TechEffect]
    let techUnlocks: [Int]
    let buildingUnlocks: [Building]
}
