import Foundation
import CoreData

class ShoppingCart: ObservableObject {
    @Published var items: [Product: Int] = [:]
    
    func add(product: Product) {
        if items[product] != nil {
            items[product] = (items[product] ?? 0) + 1
        } else {
            items[product] = 1
        }
    }
        
    func remove(product: Product) {
            if let currentCount = items[product], currentCount > 1 {
                items[product] = (items[product] ?? 0) - 1
            } else {
                items[product] = nil
            }
        }
}
