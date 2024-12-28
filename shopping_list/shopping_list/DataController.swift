import CoreData
import Foundation


class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "ShoppingList")
    
    init() {
        container.loadPersistentStores{description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        preloadData()
    }
    
    private func preloadData() {
        let context = container.viewContext
        let category1 = Category(context: context)
        category1.name = "Category 1"
        
        
        let product1 = Product(context: context)
        product1.name = "Product 1"
        product1.category = category1
        
        let product2 = Product(context: context)
        product2.name = "Product 2"
        product2.category = category1
        
        category1.product = [product1, product2]
        
        let product3 = Product(context: context)
        product3.name = "Product 3"
        
        do {
            try context.save()
        } catch {
            print("Failed to save default data: \(error.localizedDescription)")
        }
    }
}
