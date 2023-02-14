class Resource: Encodable {
    let id: Int
    let name: String
    let count: Int
    
    init(id: Int, name: String, count: Int) {
        self.id = id
        self.name = name
        self.count = count
    }
}
