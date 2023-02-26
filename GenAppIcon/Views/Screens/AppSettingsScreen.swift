//
//  AppSettingsScreen.swift
//  GenAppIcon
//
//  Created by Kamaal M Farah on 26/02/2023.
//

import SwiftUI
import SettingsUI

struct AppSettingsScreen: View {
    var body: some View {
        SettingsScreen(configuration: SettingsConfiguration())
    }
}

struct AppSettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        AppSettingsScreen()
    }
}
