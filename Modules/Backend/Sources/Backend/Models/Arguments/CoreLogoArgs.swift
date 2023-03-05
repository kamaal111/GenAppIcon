//
//  CoreLogoArgs.swift
//  
//
//  Created by Kamaal Farah on 05/03/2023.
//

import Foundation

public struct CoreLogoArgs {
    public let data: Data
    public let configuration: CoreConfigurationArgs

    public init(data: Data, configuration: CoreConfigurationArgs) {
        self.data = data
        self.configuration = configuration
    }
}
