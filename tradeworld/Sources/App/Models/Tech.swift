import Vapor

struct Tech: Content {
    let id: Int
    let title: String
    let description: String
    let price: [ResourceQty]
    let effects: [TechEffect]
    let techUnlocks: [Int]
    let buildingUnlocks: [Building]
    
//    static var defaults: [Int] {
//        get {
//            [2, 9, 11, 12]
//        }
//    }

    public static func lookup(_ req: Request) throws -> [Tech] {
        let ids = try req.auth.require(User.self).techs
        var myTechs: [Tech] = []
        guard let techs: [Tech] = decodeFile(req: req, "techs", [Tech].self) else {
            return []
        }
        for id in ids {
            guard let tech = techs[safe: id] else {
                return []
            }
            myTechs.append(tech)
        }
        return myTechs
    }
}
