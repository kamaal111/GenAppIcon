//
//  CoreLogo.swift
//  
//
//  Created by Kamaal Farah on 05/03/2023.
//

import CoreData
import CDPersist
import Foundation

extension CoreLogo {
    var toAppLogo: AppLogo {
        AppLogo(id: id, data: data, configuration: configuration.toAppLogoConfiguration)
    }

    func update(with args: CoreLogoArgs, save: Bool = true) throws -> CoreLogo {
        let now = Date()
        self.updateDate = now
        self.data = args.data

        self.configuration.updateDate = now
        self.configuration.cornerRadius = args.configuration.cornerRadius
        self.configuration.brightness = args.configuration.brightness

        if save {
            try self.managedObjectContext?.save()
        }

        return self
    }

    static func create(from args: CoreLogoArgs, context: NSManagedObjectContext) throws -> CoreLogo {
        let now = Date()
        let logo = CoreLogo(context: context)
        logo.kCreationDate = now
        logo.id = UUID()
        logo.updateDate = now
        logo.data = args.data

        let configuration = CoreLogoConfiguration(context: context)
        configuration.kCreationDate = now
        configuration.id = UUID()
        configuration.updateDate = now
        configuration.cornerRadius = args.configuration.cornerRadius
        configuration.brightness = args.configuration.brightness
        configuration.logo = logo
        logo.configuration = configuration

        try context.save()

        return logo
    }
}
