import SwiftUI

struct CartView: View {
    @EnvironmentObject var cart: ShoppingCart
    @State private var confirmationMessage = ""
    @State private var showingConfirmation = false
    
    var body: some View {
        NavigationStack {
                let totalCost = cart.items.reduce(Decimal(0)) { result, pair in
                    let (product, count) = pair
                    return result + (product.wrappedPrice * Decimal(count))
                }

                VStack {
                    List {
                        ForEach(Array(cart.items), id: \.key) { (product, count) in
                            HStack {
                                Text(product.wrappedName)
                                Spacer()
                                Text("Price: \(String(format: "%.2f", Double(truncating: product.wrappedPrice * Decimal(count) as NSNumber)))$")
                            }
                        }
                    }

                    Spacer()

                    Text("Total: \(String(format: "%.2f", Double(truncating: totalCost as NSNumber)))$")
                        .font(.headline)
                        .padding()
                    NavigationLink(destination: CheckoutView()) {
                        Text("Checkout")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
//                        Task {
//                            await placeOrder()
//                        }
                }
                .navigationTitle("Your Cart")
                .alert("Thank you!", isPresented: $showingConfirmation) {
                    Button("OK") { }
                } message: {
                    Text(confirmationMessage)
                }
            }
    }
    
    func placeOrder() async {
        var apiItems: [String: Int] = [:]
        for (product, quantity) in cart.items {
            let id = product.id
            apiItems[id] = quantity
        }
        let order = Order(items: apiItems)
        guard let encoded = try? JSONEncoder().encode(order) else {
            print("Failed to encode order")
            return
        }
        
        let url = URL(string: "http://127.0.0.1:8000/orders")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            let decodedOrder = try JSONDecoder().decode(Order.self, from: data)
            confirmationMessage = "Your order \(decodedOrder.id) is on its way!"
            showingConfirmation = true
        } catch {
            print("Checkout failed: \(error.localizedDescription)")
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
            HStack {
                Button(action: {
                    cart.remove(product: product)
                }) {
                    Text("-")
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.red))
                }
                
                Text("\(cart.items[product] ?? 0)")
                    .font(.title2)
                    .frame(width: 50, alignment: .center)
                
                Button(action: {
                    cart.add(product: product)
                }) {
                    Text("+")
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.green))
                }
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
            UserProfileView()
                .tabItem {
                    Label("My profile", systemImage: "person.crop.circle")
            }
            
            
        }
    }
}

#Preview {
    MainView()
        .environmentObject(ShoppingCart())
}
