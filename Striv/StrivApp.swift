//
//  StrivApp.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/12/2025.
//

import SwiftUI
import SwiftData
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

import SwiftUI
import SwiftData

@main
struct StrivApp: App {
    
    let container: ModelContainer
    
    init() {
        do {
            guard let groupURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.striv"
            ) else {
                fatalError("App Group introuvable")
            }
            
            let supportURL = groupURL
                .appendingPathComponent("Library/Application Support", isDirectory: true)
            
            try FileManager.default.createDirectory(
                at: supportURL,
                withIntermediateDirectories: true
            )
            
            let storeURL = supportURL.appendingPathComponent("default.store")
            
            let config = ModelConfiguration(url: storeURL)
            
            container = try ModelContainer(
                for: Workout.self,
                Duration.self,
                Coordinate.self,
                RunnerProfile.self,
                RunSample.self,
                configurations: config
            )
            
        } catch {
            fatalError("SwiftData init failed: \(error)")
        }
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
