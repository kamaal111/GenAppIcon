//
//  File.swift
//  
//
//  Created by Kamaal Farah on 05/03/2023.
//

import Foundation

public struct AppLogo: Identifiable, Hashable {
    public let id: UUID
    public let data: Data
    public let configuration: AppLogoConfiguration

    public init(id: UUID, data: Data, configuration: AppLogoConfiguration) {
        self.id = id
        self.data = data
        self.configuration = configuration
    }
}
