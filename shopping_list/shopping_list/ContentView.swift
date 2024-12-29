import SwiftUI

struct CartView: View {
    @EnvironmentObject var cart: ShoppingCart
    
    var body: some View {
        NavigationStack {
            VStack {
                List(cart.items) { item in
                    HStack {
                        Text(item.wrappedName)
                        Spacer()
                        Text("\(item.wrappedPrice)$")
                    }
                    
                }
                Section {
                                Text("Total: \(cart.items.reduce(Decimal(0)) { $0 + $1.wrappedPrice })$")
                                    .font(.headline)
                                    .padding()
                            }
                
            }
            .navigationTitle("Your Cart")
        }
    }
}

struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var cart: ShoppingCart

    var body: some View {
        VStack {
            Text("Product Name: \(product.wrappedName)")
                .font(.title)
            if let category = product.category {
                Text("Category: \(category.wrappedName)")
            } else {
                Text("Category: None")
            }
            Text("Price: \(String(format: "%.2f", Double(truncating: product.wrappedPrice as NSNumber)))$")
            Button("Add to cart") {
                cart.add(product: product)
            }
            .buttonStyle(.borderedProminent)
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
                .tabItem {
                    Label("Order", systemImage: "square.and.pencil")
                }
                
            }
    }
}

struct MainView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Menu", systemImage: "list.dash")
                }
            CartView()
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(ShoppingCart())
}
