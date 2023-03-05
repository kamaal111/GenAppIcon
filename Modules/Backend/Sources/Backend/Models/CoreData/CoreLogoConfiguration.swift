//
//  CoreLogoConfiguration.swift
//  
//
//  Created by Kamaal Farah on 05/03/2023.
//

import CoreData
import CDPersist
import Foundation

extension CoreLogoConfiguration {
    var toAppLogoConfiguration: AppLogoConfiguration {
        AppLogoConfiguration(id: id, cornerRadius: cornerRadius)
    }

    func update(with args: CoreConfigurationArgs, save: Bool = true) throws -> CoreLogoConfiguration {
        self.updateDate = Date()
        self.cornerRadius = args.cornerRadius

        if save {
            try self.managedObjectContext?.save()
        }

        return self
    }
}
