//
//  SimDirsApp.swift
//  SimDirs
//
//  Created by Casey Fleser on 5/23/22.
//

import SwiftUI

@main
struct SimDirsApp: App {
    @StateObject private var modelData = PresentableModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelData)
        }
        .commands {
            SimCommands()
        }
    }
}

struct SimCommands: Commands {
    var body: some Commands {
        SidebarCommands()

        CommandMenu("Commands") {
            Button("Command") {
                print("Command")
            }
            .keyboardShortcut("f", modifiers: [.shift, .option])
        }
    }
}
