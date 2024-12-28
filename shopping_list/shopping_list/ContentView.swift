import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc 
    @FetchRequest(sortDescriptors: []) var products: FetchedResults<Product>
    
    var body: some View {
        VStack {
            List(products) { product in
                Text(product.name ?? "Unknown")
                
            }
        }
    }
}

#Preview {
    ContentView()
}
