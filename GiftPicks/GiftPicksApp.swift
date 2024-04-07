//
//  GiftPicksApp.swift
//  GiftPicks
//
//  Created by Shriyan Gote on 4/5/24.
//

import SwiftUI

@main
struct GiftPicksApp: App {
    // Add a state variable to track the user's authentication status
    @State private var isAuthenticated = false
    @StateObject private var globalSettings = GlobalSettings()  // Initialize GlobalSettings here


    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                ContentView(isAuthenticated: $isAuthenticated).environmentObject(GlobalSettings())

            } else{
                LoginView(isAuthenticated: $isAuthenticated)// Pass isAuthenticated binding to LoginView
            }
        }
    }
}
