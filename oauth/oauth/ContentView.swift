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
                    Button("Place Order") {
                        Task {
                            await placeOrder()
                        }
                    }
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

struct UserProfileView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var currentView: ProfileViewState = .login

    var body: some View {
        VStack {
            switch currentView {
            case .login:
                LoginView(onRegister: {
                    currentView = .register
                }, onLoginSuccess: {
                    currentView = .profile
                })
            case .register:
                RegisterView(onRegisterSuccess: {
                    currentView = .profile
                }, onCancel: {
                    currentView = .login
                })
            case .profile:
                ProfileDetailView(onLogout: {
                    sessionManager.logOut()
                    currentView = .login
                })
            }
        }
    }
}

enum ProfileViewState {
    case login, register, profile
}

struct LoginView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var password = ""
    @State private var errorMessage: String?
    let onRegister: () -> Void
    let onLoginSuccess: () -> Void

    var body: some View {
        VStack {
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            TextField("Username", text: $sessionManager.username)
                .autocapitalization(.none)
                .autocorrectionDisabled(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button("Log In") {
                authenticate()
            }
            .padding()

            Button("Don't have an account? Register") {
                onRegister()
            }
            .padding()
        }
        .padding()
    }

    func authenticate() {
        guard let url = URL(string: "http://127.0.0.1:8000/login") else {
            errorMessage = "Invalid URL"
            return
        }

        let loginDetails = [
            "username": sessionManager.username,
            "password": password
        ]
        
        password = ""
        
        guard let body = try? JSONSerialization.data(withJSONObject: loginDetails) else {
            errorMessage = "Failed to encode login details"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Error: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data in response"
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let token = json["token"] as? String {
                        DispatchQueue.main.async {
                            sessionManager.logIn(token: token, username: sessionManager.username)
                            errorMessage = nil
                        }
                    } else {
                        DispatchQueue.main.async {
                            errorMessage = "Invalid response format"
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        errorMessage = "Failed to parse response"
                    }
                }
                onLoginSuccess()
            } else {
                DispatchQueue.main.async {
                    errorMessage = "Invalid credentials"
                }
            }
        }.resume()
    }
}



struct RegisterView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var password = ""
    @State private var errorMessage: String?
    let onRegisterSuccess: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack {
            Text("Register")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            TextField("Username", text: $sessionManager.username)
                .autocapitalization(.none)
                .autocorrectionDisabled(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button("Register") {
                register()
            }
            .padding()

            Button("Cancel") {
                onCancel()
            }
            .padding()
        }
        .padding()
    }

    func register() {
        guard let url = URL(string: "http://127.0.0.1:8000/register") else {
            errorMessage = "Invalid URL"
            return
        }

        let registrationDetails = [
            "username": sessionManager.username,
            "password": password
        ]

        password = ""

        guard let body = try? JSONSerialization.data(withJSONObject: registrationDetails) else {
            errorMessage = "Failed to encode registration details"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Error: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data in response"
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let token = json["token"] as? String {
                        DispatchQueue.main.async {
                            sessionManager.logIn(token: token, username: sessionManager.username)
                            errorMessage = nil
                        }
                    } else {
                        DispatchQueue.main.async {
                            errorMessage = "Invalid response format"
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        errorMessage = "Failed to parse response"
                    }
                }
                onRegisterSuccess()
            } else {
                DispatchQueue.main.async {
                    errorMessage = "Registration failed"
                }
            }
        }.resume()
    }
}



struct ProfileDetailView: View {
    @EnvironmentObject var sessionManager: SessionManager
    let onLogout: () -> Void

    var body: some View {
        VStack {
            Text("My Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Text("Username: \(sessionManager.username)")
                .font(.title)

            Button("Log Out") {
                onLogout()
            }
            .padding()
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
