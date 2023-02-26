//
//  Screens.swift
//  GenAppIcon
//
//  Created by Kamaal M Farah on 25/02/2023.
//

import GALocales
import Foundation
import BetterNavigation

enum Screens: Int, Hashable, Identifiable, CaseIterable, NavigatorStackValue {
    case generator = 0
    case settings = 1

    static var root: Screens {
        .generator
    }

    var isTabItem: Bool {
        false
    }

    var isSideTab: Bool {
        switch self {
        case .generator, .settings:
            return true
        }
    }

    var title: String {
        switch self {
        case .generator:
            return GALocales.getText(.GENERATOR)
        case .settings:
            return GALocales.getText(.SETTINGS)
        }
    }

    var imageSystemName: String {
        switch self {
        case .generator:
            return "flame"
        case .settings:
            return "gearshape"
        }
    }

    var id: UUID {
        switch self {
        case .generator:
            return UUID(uuidString: "0f50db47-f586-4b34-8a63-565097a8fce3")!
        case .settings:
            return UUID(uuidString: "ead63f04-3ca0-4fa1-929e-826747eff6a8")!
        }
    }
}
