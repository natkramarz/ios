import SwiftUI

struct ContentView: View {
    @State private var display = "0"
    @State private var input = ""
    @State private var operation: String?
    @State private var storedValue: Double? = 0
    
    func onClick(_ button: ButtonInfo) {
        switch button.label {
        case "+", "-", "*", "/":
            operation = button.label
            storedValue = Double(input)
            input = ""
        case ",":
            if !display.contains(",") {
                input += button.label
            }
        case "=":
            print("need to present result")
            print("handle errors")
        default:
            if input.count < 9 {
                input += button.label
            }
        }
        if input.isEmpty {
            display = "0"
        } else {
            display = input
        }
    }
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            VStack {
                HStack {
                    Text(display)
                        .font(.system(size:100))
                        .foregroundColor(Color.white)
                        .padding(.trailing, 24)
                }
                
                HStack {
                    ButtonRow(buttons: [
                        ButtonInfo(label: "AC", backgroundColor: .pink, foregroundColor: .white)], action: onClick)
                    .padding(.leading, 12)
                    Spacer()
                }
                
                ButtonRow(buttons: [
                    ButtonInfo(label: "7", backgroundColor: .gray, foregroundColor: .white),
                    ButtonInfo(label: "8", backgroundColor: .gray, foregroundColor: .white),
                    ButtonInfo(label: "9", backgroundColor: .gray, foregroundColor: .white),
                    ButtonInfo(label: "x", backgroundColor: .orange,  foregroundColor: .white),
                ], action: onClick)
                    
                ButtonRow(buttons: [
                    ButtonInfo(label: "4", backgroundColor: .gray, foregroundColor: .white),
                    ButtonInfo(label: "5", backgroundColor: .gray, foregroundColor: .white),
                    ButtonInfo(label: "6", backgroundColor: .gray, foregroundColor: .white),
                    ButtonInfo(label: "-", backgroundColor: .orange,  foregroundColor: .white)
                    
                ], action: onClick)
                ButtonRow(buttons: [
                    ButtonInfo(label: "1", backgroundColor: .gray, foregroundColor: .white),
                    ButtonInfo(label: "2", backgroundColor: .gray, foregroundColor: .white),
                    ButtonInfo(label: "3", backgroundColor: .gray, foregroundColor: .white),
                    ButtonInfo(label: "+", backgroundColor: .orange,  foregroundColor: .white)
                    
                ], action: onClick)
                ButtonRow(buttons: [
                    ButtonInfo(label: "0", backgroundColor: .gray, foregroundColor: .white),
                    ButtonInfo(label: ",", backgroundColor: .gray, foregroundColor: .white),
                    ButtonInfo(label: "=", backgroundColor: .orange,  foregroundColor: .white),
                    ButtonInfo(label: "/", backgroundColor: .orange, foregroundColor: .white),
                ], action: onClick)
            }
        
        }
    }
}

struct ButtonInfo {
    let label: String
    let backgroundColor: Color
    let foregroundColor: Color
}

struct ButtonRow: View {
    let buttons: [ButtonInfo]
    var action: (ButtonInfo) -> Void
    
    var body: some View {
        let buttonSize = (UIScreen.main.bounds.width - 5 * 12) / 4
        HStack(spacing: 12) {
            
            ForEach(buttons, id: \.label) { buttonInfo in
                Button(action: {
                    action(buttonInfo)
                }){
                    Text(buttonInfo.label)
                        .foregroundColor(buttonInfo.foregroundColor)
                        .font(.title)
                        .frame(width: buttonSize, height: buttonSize)
                        .background(buttonInfo.backgroundColor)
                        .clipShape(Circle())
                    
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
