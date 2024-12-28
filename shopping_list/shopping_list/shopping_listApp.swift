import SwiftUI
import CoreData

@main
struct shopping_listApp: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
            WindowGroup {
                ContentView()
                    .environment(\.managedObjectContext, dataController.container.viewContext)
            }
        }
}
