//
//  BaseProperties.swift
//  
//
//  Created by Kamaal Farah on 05/03/2023.
//

import ManuallyManagedObject

let baseProperties: [ManagedObjectPropertyConfiguration] = [
    ManagedObjectPropertyConfiguration(name: "updateDate", type: .date, isOptional: false),
    ManagedObjectPropertyConfiguration(name: "kCreationDate", type: .date, isOptional: false),
    ManagedObjectPropertyConfiguration(name: "id", type: .uuid, isOptional: false),
]
