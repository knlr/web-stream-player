//
//  StreamPlayerApp.swift
//  StreamPlayer
//
//  Created by Knut on 08/04/2024.
//

import SwiftUI
import SwiftData

@main
struct StreamPlayerApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @State var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            StreamList.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let mc = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let streamList = try mc.mainContext.fetch(FetchDescriptor<StreamList>())
            if streamList.isEmpty {
                mc.mainContext.insert(StreamList(streams: []))
                try mc.mainContext.save()
            }
            return mc
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

@MainActor
class SceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print(#function)
        
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {

        let configuration = UISceneConfiguration(
                                name: nil,
                                sessionRole: connectingSceneSession.role)
        if connectingSceneSession.role == .windowApplication {
            configuration.delegateClass = SceneDelegate.self
        }
        return configuration
    }
}
