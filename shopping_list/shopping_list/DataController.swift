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
        //preloadData()
    }
    
    private func preloadData() {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                loadDefaultData(context: context)
            }
        } catch {
            print("Error checking data store: \(error.localizedDescription)")
        }
    }
    
    private func loadDefaultData(context: NSManagedObjectContext) {
        let product1 = Product(context: context)
        product1.id = UUID()
        product1.name = "Product 1"
        
        let product2 = Product(context: context)
        product2.id = UUID()
        product2.name = "Product 2"
        
        let product3 = Product(context: context)
        product3.id = UUID()
        product3.name = "Product 3"
        
        do {
            try context.save()
        } catch {
            print("Failed to save default data: \(error.localizedDescription)")
        }
    }
}
