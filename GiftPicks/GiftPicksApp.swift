//
//  GiftPicksApp.swift
//  GiftPicks
//
//  Created by Shriyan Gote on 4/5/24.
//

import SwiftUI
import AWSS3

@main
struct GiftPicksApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var isAuthenticated = false
    @StateObject private var globalSettings = GlobalSettings()
    @StateObject private var s3Downloader = S3Downloader()

    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                ContentView(isAuthenticated: $isAuthenticated, settings: globalSettings)
                    .environmentObject(globalSettings)
                    .onAppear {
                        print("hello")
                        s3Downloader.downloadJsonFile()
                    }
            } else {
                LoginView(isAuthenticated: $isAuthenticated)
            }
        }
    }
}



class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Set up AWS configuration first thing.
        initializeAWSS3()

        // Other setup can go here.
        return true
    }

    func initializeAWSS3() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USWest1, identityPoolId: "us-west-1:df592e08-4c1c-4bab-9e7f-f33d4e59503a")
        let configuration = AWSServiceConfiguration(region: .USWest1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
}


