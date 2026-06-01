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

enum StrivSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Workout.self,
         Duration.self,
         Coordinate.self,
         RunnerProfile.self,
         RunSampleEntity.self,]
    }
}

enum StrivMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [StrivSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}

@main
struct StrivApp: App {
    
    @StateObject var errorPresenter = ErrorPresenter()
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
                RunSampleEntity.self,
                configurations: config
            )
            
        } catch {
            print("SwiftData init failed: \(error)")
            
            container = try! ModelContainer(
                for: Workout.self,
                Duration.self,
                Coordinate.self,
                RunnerProfile.self,
                RunSampleEntity.self
            )
        }
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @AppStorage("hasSeenOnBoarding")
    var hasSeenOnBoarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenOnBoarding {
                    ContentView(errorPresenter: errorPresenter)
                } else {
                    OnBoardingView()
                }
            }
            .dynamicTypeSize(.xSmall ... .accessibility3)
            .environmentObject(errorPresenter)
        }
        .modelContainer(container)
    }
}
