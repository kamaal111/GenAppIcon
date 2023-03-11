//
//  GenAppIconApp.swift
//  GenAppIcon
//
//  Created by Kamaal M Farah on 25/02/2023.
//

import SwiftUI
import BetterNavigation

/// &#128511; Dare you to check!
@main
struct GenAppIconApp: App {
    @StateObject private var userData = UserData()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 300, minHeight: 300)
                .environmentObject(userData)
        }
        #if DEBUG
        .commands(content: {
            CommandGroup(replacing: .help) {
                Button(action: { Navigator<Screens>.notify(.navigate(destination: .playground)) }) {
                    Text("Playground")
                }
                .keyboardShortcut("D", modifiers: [.command, .shift])
            }
        })
        #endif
        Settings {
            AppSettingsScreen()
                .frame(minWidth: 200, minHeight: 220)
                .environmentObject(userData)
        }
    }
}
