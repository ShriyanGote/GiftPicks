// LoginView.swift
import SwiftUI

struct LoginView: View {
    @Binding public var isAuthenticated: Bool // Binding to the isAuthenticated state variable

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false // Track login status
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .padding()
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Password", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                // Perform login validation here
                // For now, simply set isAuthenticated to true for demonstration
                isAuthenticated = true
            }) {
                Text("Login")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()
            .fullScreenCover(isPresented: $isLoggedIn) {
                ContentView(isAuthenticated: $isAuthenticated) // Navigate to main page upon successful login
            }
        }
        .padding()
    }
}
