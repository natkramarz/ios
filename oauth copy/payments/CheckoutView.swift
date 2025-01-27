import SwiftUI

struct CheckoutView: View {
    let paymentTypes = ["Cash", "BLIK"]
    @State private var paymentType = "BLIK"
    
    var body: some View {
        VStack {
            
                Picker("Payment method", selection: $paymentType) {
                    ForEach(paymentTypes, id: \.self) {
                        Text($0)
                    }
                }
        }
    }
}

#Preview {
    CheckoutView()
}
