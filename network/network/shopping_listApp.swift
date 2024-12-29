import SwiftUI
import CoreData

@main
struct shopping_listApp: App {
    @StateObject private var dataController = DataController()
    @StateObject var cart = ShoppingCart()
    
    var body: some Scene {
            WindowGroup {
                MainView()
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    .environmentObject(cart)
            }
        }
}
