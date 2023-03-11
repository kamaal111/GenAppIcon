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
    #if DEBUG
    case playground = 69
    case appLogoCreator = 70
    #endif

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
        #if DEBUG
        case .playground, .appLogoCreator:
            return false
        #endif
        }
    }

    var title: String {
        switch self {
        case .generator:
            return GALocales.getText(.GENERATOR)
        case .settings:
            return GALocales.getText(.SETTINGS)
        #if DEBUG
        case .playground:
            return "Playground"
        case .appLogoCreator:
            return "Logo creator"
        #endif
        }
    }

    var imageSystemName: String {
        switch self {
        case .generator:
            return "flame"
        case .settings:
            return "gearshape"
        #if DEBUG
        case .playground, .appLogoCreator:
            return ""
        #endif
        }
    }

    var id: UUID {
        switch self {
        case .generator:
            return UUID(uuidString: "0f50db47-f586-4b34-8a63-565097a8fce3")!
        case .settings:
            return UUID(uuidString: "ead63f04-3ca0-4fa1-929e-826747eff6a8")!
        #if DEBUG
        case .playground:
            return UUID(uuidString: "583139ba-a383-4279-a24a-8a4a4a0523d3")!
        case .appLogoCreator:
            return UUID(uuidString: "1ee437a8-0582-4c3d-a881-198e69b24434")!
        #endif
        }
    }
}
