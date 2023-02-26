//
//  ContentView.swift
//  GenAppIcon
//
//  Created by Kamaal M Farah on 25/02/2023.
//

import SwiftUI
import BetterNavigation

struct ContentView: View {
    var body: some View {
        NavigationStackView(
            stack: [] as [Screens],
            root: { screen in MainView(screen: screen) },
            subView: { screen in MainView(screen: screen) },
            sidebar: { Sidebar() })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
