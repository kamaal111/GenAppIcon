//
//  GenAppIconApp.swift
//  GenAppIcon
//
//  Created by Kamaal M Farah on 25/02/2023.
//

import SwiftUI

@main
struct GenAppIconApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 300, minHeight: 300)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
