import Vapor

struct TradeContext: Content {
    let trades: [TradeTransactionResponse]
}

struct TradeTransactionResponse: Content {
    let seller: String
    let buyer: String
    let date: String
    let askResource: String
    let askAmount: Int
    let offerResource: String
    let offerAmount: Int
}
