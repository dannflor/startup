import Vapor

struct BuildingRequest: Content {
    let buildingName: String
    let index: Int
}