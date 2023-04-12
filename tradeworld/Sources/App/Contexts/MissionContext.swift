import Vapor

struct MissionContext: Content {
    let mission: Mission?
    let requirements: [ResourceProgress]
    let topFive: [MissionScore]
    let yourContrib: MissionScore
}
