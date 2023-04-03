import Vapor

struct TradeSocketResponse: Content {
    let type: TradeSocketResponseType
    let trades: [TradeResponse]
}

enum TradeSocketResponseType: String, Codable {
    case addTrades, removeTrades
}
