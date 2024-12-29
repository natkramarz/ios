import Foundation
import CoreData

class ShoppingCart: ObservableObject {
    @Published var items = [Product]()
    
    func add(product: Product) {
        items.append(product)
    }
    
    func remove(product: Product) {
        if let index = items.firstIndex(of: product) {
            items.remove(at: index)
        }
    }
}
