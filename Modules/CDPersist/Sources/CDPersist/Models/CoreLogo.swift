//
//  CoreLogo.swift
//  
//
//  Created by Kamaal Farah on 05/03/2023.
//

import CoreData
import Foundation
import ShrimpExtensions
import ManuallyManagedObject

@objc(CoreLogo)
public class CoreLogo: NSManagedObject, ManuallyManagedObject, Identifiable {
    @NSManaged public var updateDate: Date
    @NSManaged public var kCreationDate: Date
    @NSManaged public var id: UUID
    @NSManaged public var data: Data
    @NSManaged public var configuration: CoreLogoConfiguration

    public static let properties = baseProperties
        .concat([
            ManagedObjectPropertyConfiguration(name: \CoreLogo.data, type: .data, isOptional: false),
        ])

    public static let _relationships: [_RelationshipConfiguration] = [
        _RelationshipConfiguration(
            name: "configuration",
            destinationEntity: CoreLogoConfiguration.self,
            inverseRelationshipName: "logo",
            inverseRelationshipEntity: CoreLogo.self,
            isOptional: false,
            relationshipType: .toOne
        ),
    ]
}
