//
//  CoreLogoConfiguration.swift
//  
//
//  Created by Kamaal Farah on 05/03/2023.
//

import CoreData
import Foundation
import ShrimpExtensions
import ManuallyManagedObject

@objc(CoreLogoConfiguration)
public class CoreLogoConfiguration: NSManagedObject, ManuallyManagedObject, Identifiable {
    @NSManaged public var updateDate: Date
    @NSManaged public var kCreationDate: Date
    @NSManaged public var id: UUID
    @NSManaged public var cornerRadius: Double
    @NSManaged public var brightness: Double
    @NSManaged public var logo: CoreLogo

    public static let properties = baseProperties
        .concat([
            ManagedObjectPropertyConfiguration(
                name: \CoreLogoConfiguration.cornerRadius,
                type: .double,
                isOptional: false),
            ManagedObjectPropertyConfiguration(
                name: \CoreLogoConfiguration.brightness,
                type: .double,
                isOptional: false),
        ])

    public static let _relationships: [_RelationshipConfiguration] = [
        _RelationshipConfiguration(
            name: "logo",
            destinationEntity: CoreLogo.self,
            inverseRelationshipName: "configuration",
            inverseRelationshipEntity: CoreLogoConfiguration.self,
            isOptional: false,
            relationshipType: .toOne
        ),
    ]
}
