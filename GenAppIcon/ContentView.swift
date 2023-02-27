//
//  ContentView.swift
//  GenAppIcon
//
//  Created by Kamaal M Farah on 25/02/2023.
//

import SwiftUI
import PopperUp
import BetterNavigation

struct ContentView: View {
    @StateObject private var popperUpManager = PopperUpManager()

    var body: some View {
        NavigationStackView(
            stack: [] as [Screens],
            root: { screen in MainView(screen: screen).withPopperUp(popperUpManager) },
            subView: { screen in MainView(screen: screen).withPopperUp(popperUpManager) },
            sidebar: { Sidebar() })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
