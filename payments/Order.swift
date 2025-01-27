import Foundation

class Order: Codable {
    let id: String
    let customerId: String
    var items: [String: Int] = [:]
    var payment: Payment
    var createdAt: Date
    var updatedAt: Date
    

    init(customerId: String, items: [String: Int] = [:], payment: Payment, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.customerId = customerId
        self.id = UUID().uuidString
        self.items = items
        self.payment = payment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    private enum CodingKeys: String, CodingKey {
        case id, items, payment
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case customerId = "customer_id"
    }

    class Payment: Codable {
        let id: String
        var status: Status
        var method: Method
        let amount: Decimal

        init(status: Status, method: Method) {
            self.id = UUID().uuidString
            self.status = status
            self.method = method
            self.amount = 0
        }

        private enum CodingKeys: String, CodingKey {
            case id, status, method, amount
        }

        enum Status: String, Codable {
            case pending = "Pending"
            case completed = "Completed"
            case failed = "Failed"
        }

        enum Method: String, Codable {
            case cash = "Cash"
            case blik = "BLIK"
        }
    }
}
