//
//  PersistenceController.swift
//  
//
//  Created by Kamaal Farah on 05/03/2023.
//

import CoreData
import Foundation
import ShrimpExtensions
import ManuallyManagedObject

public class PersistenceController {
    private let container: NSPersistentContainer

    private init(inMemory: Bool = false) {
        let containerName = "GenAppIcon"
        let persistentContainerBuilder = _PersistentContainerBuilder(
            entities: [
                CoreLogo.entity,
                CoreLogoConfiguration.entity,
            ],
            relationships: CoreLogo._relationships
                .concat(CoreLogoConfiguration._relationships),
            containerName: containerName,
            preview: inMemory
        )
        self.container = persistentContainerBuilder.make()

        if !inMemory, let defaultURL = container.persistentStoreDescriptions.first?.url {
            let defaultStore = NSPersistentStoreDescription(url: defaultURL)
            defaultStore.configuration = "Default"
            defaultStore.shouldMigrateStoreAutomatically = false
            defaultStore.shouldInferMappingModelAutomatically = true
        }

        container.viewContext.automaticallyMergesChangesFromParent = true

        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }

    public var context: NSManagedObjectContext {
        container.viewContext
    }

    public static let shared = PersistenceController()

    public static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        return result
    }()
}
