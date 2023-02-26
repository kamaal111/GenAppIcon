//
//  Sidebar.swift
//  GenAppIcon
//
//  Created by Kamaal M Farah on 25/02/2023.
//

import SwiftUI
import GALocales
import BetterNavigation

struct Sidebar: View {
    var body: some View {
        List {
            if !screens.isEmpty {
                Section(GALocales.getText(.SCENES)) {
                    ForEach(screens) { screen in
                        StackNavigationChangeStackButton(destination: screen) {
                            Label(screen.title, systemImage: screen.imageSystemName)
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .toolbar(content: {
            Button(action: toggleSidebar) {
                Label(GALocales.getText(.TOGGLE_SIDEBAR), systemImage: "sidebar.left")
                    .foregroundColor(.accentColor)
            }
        })
    }

    private var screens: [Screens] {
        Screens.allCases.filter(\.isSideTab)
    }

    private func toggleSidebar() {
        guard let firstResponder = NSApp.keyWindow?.firstResponder else { return }
        firstResponder.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar()
    }
}
