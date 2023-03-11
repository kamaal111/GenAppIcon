//
//  UserData.swift
//  GenAppIcon
//
//  Created by Kamaal M Farah on 11/03/2023.
//

import Foundation
import SettingsUI

final class UserData: ObservableObject {
    @Published private var showLogs = true

    var settingsConfiguration: SettingsConfiguration {
        var feedback: SettingsConfiguration.FeedbackConfiguration?
        if let token = SecretsJSON.shared.content?.gitHubToken {
            feedback = .init(
                token: token,
                username: "kamaal111",
                repoName: "GenAppIcon",
                additionalLabels: ["macOS"])
        }

        return SettingsConfiguration(feedback: feedback, showLogs: showLogs)
    }
}
