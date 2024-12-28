import SwiftUI

struct ProductDetailView: View {
    let product: Product

    var body: some View {
        VStack {
            Text("Product Name: \(product.wrappedName)")
                .font(.title)
            
            if let category = product.category {
                Text("Category: \(category.wrappedName)")
                    .font(.subheadline)
            } else {
                Text("Category: None")
                    .font(.subheadline)
            }
        }
        .padding()
        .navigationTitle(product.wrappedName)
    }
}


struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var products: FetchedResults<Product>
    
    var body: some View {
            NavigationView {
                List(products) { product in
                    NavigationLink(destination: ProductDetailView(product: product)) {
                        Text(product.wrappedName)
                    }
                }
                .navigationTitle("Products")
            }
    }
}

#Preview {
    ContentView()
}
