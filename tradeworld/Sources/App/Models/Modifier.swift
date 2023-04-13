import Vapor

struct Modifier: Content {
    let yieldBonus: [String: [ResourceQty]]
    let bonusBonus: [String: [ResourceQty]]
    
}

enum ModifyType: String, Content {
    case bonus, direction, yield
}