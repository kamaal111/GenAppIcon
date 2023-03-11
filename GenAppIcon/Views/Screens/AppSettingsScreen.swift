//
//  AppSettingsScreen.swift
//  GenAppIcon
//
//  Created by Kamaal M Farah on 26/02/2023.
//

import SwiftUI
import SettingsUI

struct AppSettingsScreen: View {
    @EnvironmentObject private var userData: UserData

    var body: some View {
        SettingsScreen(configuration: userData.settingsConfiguration)
    }
}

struct AppSettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        AppSettingsScreen()
    }
}
