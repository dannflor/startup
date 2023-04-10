import Vapor
import Fluent

final class TradeTransaction: Model, Content {
    init() { }
    
    static let schema: String = "trade_transaction"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "seller_id")
    var seller: User
    
    @Parent(key: "buyer_id")
    var buyer: User

    @Field(key: "created_at")
    var createdAt: Date
    
    @Field(key: "offer_amount")
    var offerAmount: Int
    
    @Field(key: "offer_resource")
    var offerResource: ResourceType
    
    @Field(key: "ask_amount")
    var askAmount: Int
    
    @Field(key: "ask_resource")
    var askResource: ResourceType
    
    init(id: UUID? = nil, seller: UUID, buyer: UUID, createdAt: Date = Date.now, offerAmount: Int, offerResource: ResourceType, askAmount: Int, askResource: ResourceType) {
        self.id = id
        self.$seller.id = seller
        self.$buyer.id = buyer
        self.createdAt = createdAt
        self.offerAmount = offerAmount
        self.offerResource = offerResource
        self.askAmount = askAmount
        self.askResource = askResource
    }
}
