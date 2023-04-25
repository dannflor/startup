struct Config: Codable {
    let showPopup: Bool
    let popup: Popup
}

struct Popup: Codable {
    let name: String
    let title: String
    let content: String
}