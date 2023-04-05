import Vapor

struct TradeSocketResponse: Content {
    let type: TradeSocketResponseType
    let trades: [TradeResponse]
}

enum TradeSocketResponseType: String, Codable {
    case addTrades, removeTrades
}

struct TradeSocketRequest: Content {
    let type: TradeSocketRequestType
    let trade: TradeResponse
}

enum TradeSocketRequestType: String, Codable {
    case addTrade, acceptTrade
}
