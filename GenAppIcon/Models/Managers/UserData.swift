//
//  UserData.swift
//  GenAppIcon
//
//  Created by Kamaal M Farah on 11/03/2023.
//

import SwiftUI
import GALocales
import SettingsUI

final class UserData: ObservableObject {
    @Published private var showLogs = true
    @Published private var appColor = UserData.appColors[0]

    var settingsConfiguration: SettingsConfiguration {
        var feedback: SettingsConfiguration.FeedbackConfiguration?
        if let token = SecretsJSON.shared.content?.gitHubToken {
            feedback = .init(
                token: token,
                username: "kamaal111",
                repoName: "GenAppIcon",
                additionalLabels: ["macOS"])
        }

        return SettingsConfiguration(feedback: feedback, color: colorConfiguration, showLogs: showLogs)
    }

    private var colorConfiguration: SettingsConfiguration.ColorsConfiguration {
        .init(colors: [appColor], currentColor: appColor)
    }

    private static let appColors: [AppColor] = [
        AppColor(
            id: UUID(uuidString: "9e3ea7fa-1cf9-4254-9e27-9ace0fbe3d4f")!,
            name: GALocales.getText(.DEFAULT_COLOR),
            color: Color("AccentColor"))
    ]
}
