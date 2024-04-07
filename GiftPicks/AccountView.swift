import SwiftUI

struct AccountView: View {
    var changePage: () -> Void  // Closure to change the page

    var body: some View {
        VStack {
            Text("Account Page")
            // Add more UI elements specific to the Entries page here

            Button("Back to Board") {
                changePage()  // Call the closure to change the page
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
