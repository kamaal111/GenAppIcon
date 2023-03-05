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
            root: { screen in MainView(screen: screen) },
            subView: { screen in MainView(screen: screen) },
            sidebar: { Sidebar() })
        .withPopperUp(popperUpManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
