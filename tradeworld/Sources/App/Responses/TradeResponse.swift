import Vapor
import Fluent

struct TradeResponse: Content {
    let id: UUID?
    let seller: String
    let message: String
    let offer: ResourceQty
    let ask: ResourceQty
    
    init(_ trade: Trade, _ db: Database) async throws {
        self.id = trade.id
        self.seller = trade.seller
        self.message = trade.message
        if let dbOffer = try await trade.$offer.get(on: db) {
            self.offer = ResourceQty(name: dbOffer.name, count: dbOffer.count)
        }
        else {
            self.offer = ResourceQty(name: .Gold, count: 0)
        }
        if let dbAsk = try await trade.$ask.get(on: db) {
            self.ask = ResourceQty(name: dbAsk.name, count: dbAsk.count)
        }
        else {
            self.ask = ResourceQty(name: .Gold, count: 0)
        }
    }
}
