//
//  File.swift
//  
//
//  Created by Kamaal Farah on 05/03/2023.
//

import Foundation

public struct AppLogoConfiguration: Identifiable, Hashable {
    public let id: UUID
    public let cornerRadius: Double
    public let brightness: Double

    public init(id: UUID, cornerRadius: Double, brightness: Double) {
        self.id = id
        self.cornerRadius = cornerRadius
        self.brightness = brightness
    }
}
