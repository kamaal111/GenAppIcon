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
    }
}
