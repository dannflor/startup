struct Trade: Encodable {
    let id: Int
    let seller: String
    let message: String
    let offer: ResourceQty
    let ask: ResourceQty
}
