import Vapor
import Fluent

final class Trade: Model {
    init() { }
    
    static let schema: String = "trade"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "seller")
    var seller: String
    
    @Field(key: "message")
    var message: String

    @Field(key: "created_at")
    var createdAt: Date
    
    @OptionalChild(for: \.$trade)
    var offer: Offer?
    
    @OptionalChild(for: \.$trade)
    var ask: Ask?
    
    init(id: UUID? = nil, seller: String, message: String, createdAt: Date = Date.now) {
        self.id = id
        self.seller = seller
        self.message = message
    }
}

final class Offer: Model {
    init() { }
    
    static let schema: String = "offer"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: ResourceType
    
    @Field(key: "count")
    var count: Int
    
    @Parent(key: "trade_id")
    var trade: Trade
    
    init(id: UUID? = nil, name: ResourceType, count: Int, tradeId: UUID) {
        self.id = id
        self.name = name
        self.count = count
        self.$trade.id = tradeId
    }
}

final class Ask: Model {
    init() { }
    
    static let schema: String = "ask"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: ResourceType
    
    @Field(key: "count")
    var count: Int
    
    @Parent(key: "trade_id")
    var trade: Trade
    
    init(id: UUID? = nil, name: ResourceType, count: Int, tradeId: UUID) {
        self.id = id
        self.name = name
        self.count = count
        self.$trade.id = tradeId
    }
}
