//
//  MainView.swift
//  GenAppIcon
//
//  Created by Kamaal M Farah on 25/02/2023.
//

import SwiftUI
import SalmonUI

struct MainView: View {
    let screen: Screens

    init(screen: Screens?) {
        self.screen = screen ?? .root
    }

    init(_ screen: Screens) {
        self.screen = screen
    }

    var body: some View {
        KJustStack {
            switch screen {
            case .generator:
                GeneratorScreen()
            case .settings:
                AppSettingsScreen()
            #if DEBUG
            case .playground:
                PlaygroundScreen()
            case .appLogoCreator:
                PlaygroundAppLogoCreatorScreen()
            #endif
            }
        }
        .navigationTitle(screen.title)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(Screens.allCases, id: \.self) { screen in
            MainView(screen)
        }
    }
}
