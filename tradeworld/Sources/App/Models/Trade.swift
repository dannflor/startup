struct Trade: Encodable {
    let id: Int
    let seller: String
    let message: String
    let offer: Resource
    let ask: Resource
}
