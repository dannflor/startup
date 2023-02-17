import Vapor

struct Building: Content {
    let name: String
    let cost: [ResourceQty]
    let img: String
}
