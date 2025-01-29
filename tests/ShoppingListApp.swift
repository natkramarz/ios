import SwiftUI
import CoreData

@main
struct ShoppingListApp: App {
    @StateObject private var dataController = DataController()
    @StateObject var cart = ShoppingCart()
    @StateObject private var sessionManager = SessionManager()
    
    var body: some Scene {
            WindowGroup {
                MainView()
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    .environmentObject(cart)
                    .environmentObject(sessionManager)
            }
    }
}
