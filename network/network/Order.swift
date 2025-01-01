import Foundation

class Order: Codable {
    let id: String
    var items:  [String: Int] = [:]
    
    
    init(items: [String: Int] = [:]){
        self.id = UUID().uuidString
        self.items = items
    }

    private enum CodingKeys: String, CodingKey {
        case id, items
    }
}
