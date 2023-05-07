import Vapor

struct Mission: Content {
    let name: String
    let description: String
    let ongoing: Bool
    let winningMessage: String
    let requirements: [ResourceQty]
    let img: String
    
    static func current(req: Request) -> Mission? {
        return decodeFile(req: req, "mission", Mission.self)
    }
}
