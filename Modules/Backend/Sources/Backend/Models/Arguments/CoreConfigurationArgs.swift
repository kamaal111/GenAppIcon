//
//  CoreConfigurationArgs.swift
//  
//
//  Created by Kamaal Farah on 05/03/2023.
//

import Foundation

public struct CoreConfigurationArgs {
    public let cornerRadius: Double
    public let brightness: Double

    public init(cornerRadius: Double, brightness: Double) {
        self.cornerRadius = cornerRadius
        self.brightness = brightness
    }
}
