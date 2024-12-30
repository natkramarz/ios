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
        deleteAllData(entityName: "Category", context: context)
        deleteAllData(entityName: "Product", context: context)
        
        ProductsApi().getProducts { CategoriesResponse in
            for category in CategoriesResponse.categories {
                let currCategory = Category(context: context)
                currCategory.name = category.name
                
                for product in category.products {
                    let currProduct = Product(context: context)
                    currProduct.name = product.name
                    currProduct.price = product.price as NSDecimalNumber?
                    currProduct.category = currCategory
                }
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save default data: \(error.localizedDescription)")
        }
    }
    
    func deleteAllData(entityName: String, context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            try context.save()
            print("All items in \(entityName) were deleted.")
        } catch {
            print("Failed to delete items from \(entityName): \(error)")
        }
    }
}
