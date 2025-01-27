import SwiftUI

struct CheckoutView: View {
    let paymentTypes = ["Cash", "BLIK"]
    @EnvironmentObject var cart: ShoppingCart
    @EnvironmentObject var sessionManager: SessionManager
    @State private var paymentType = "Cash"
    @State private var confirmationMessage = "Success!"
    @State private var showingConfirmation = false
    @State private var blikCode = ""
    @State private var blikErrorMessage = ""
    @State private var showingBlikError = false

    var body: some View {
        Form {
            Section("Payment method") {
                Picker("Payment method", selection: $paymentType) {
                    ForEach(paymentTypes, id: \.self) {
                        Text($0)
                    }
                }
                if paymentType == "BLIK" {
                    TextField("Enter BLIK code", text: $blikCode)
                        .keyboardType(.numberPad)
                    if !blikErrorMessage.isEmpty {
                        Text(blikErrorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            Button("Place Order") {
                if validateBlikCode() {
                    // TODO: send blik to server 
                    Task {
                        await placeOrder()
                    }
                } else {
                    showingBlikError = true
                }
            }
        }
        .alert("Thank you!", isPresented: $showingConfirmation) {
            Button("OK") { }
        } message: {
            Text(confirmationMessage)
        }
        .alert("Error", isPresented: $showingBlikError) {
            Button("OK") { }
        } message: {
            Text("Invalid BLIK code. Please enter a 6-digit code.")
        }
    }

    private func validateBlikCode() -> Bool {
        if paymentType == "BLIK" {
            if blikCode.count != 6 || !blikCode.allSatisfy({ $0.isNumber }) {
                blikErrorMessage = "BLIK code must be exactly 6 digits."
                return false
            }
        }
        blikErrorMessage = ""
        return true
    }
    
    func placeOrder() async {
        showingConfirmation = true 
    }
    
    func placeOrder1() async {
        var apiItems: [String: Int] = [:]
        for (product, quantity) in cart.items {
            let id = product.id
            apiItems[id] = quantity
        }
        let payment = Order.Payment(status: .pending, method: .cash)
        let order = Order(customerId: sessionManager.username, items: apiItems, payment: payment)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard let encoded = try? encoder.encode(order) else {
            print("Failed to encode order")
            return
        }
    
        
        if let jsonString = String(data: encoded, encoding: .utf8) {
                print("JSON String: \(jsonString)")
        }
        
        let url = URL(string: "http://127.0.0.1:8000/orders")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decodedOrder = try decoder.decode(Order.self, from: data)
            confirmationMessage = "Your order \(decodedOrder.id) is on its way!"
            showingConfirmation = true
        } catch {
            print("Checkout failed: \(error)")
                if let decodingError = error as? DecodingError {
                    print("Decoding Error: \(decodingError)")
            }
        }
    }
}

#Preview {
    CheckoutView()
}
