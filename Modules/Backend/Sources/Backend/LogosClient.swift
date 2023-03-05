//
//  LogosClient.swift
//  
//
//  Created by Kamaal Farah on 05/03/2023.
//

import CoreData
import CDPersist
import Foundation

public struct LogosClient {
    private let persistenceController: PersistenceController

    public enum Errors: Error {
        case fetchFailure(context: Error)
        case createFailure(context: Error)
    }

    init(preview: Bool) {
        if preview {
            self.persistenceController = .preview
        } else {
            self.persistenceController = .shared
        }
    }

    public func getLatestUpdated() -> Result<AppLogo?, Errors> {
        let request = CoreLogo.fetchRequest()
        let sorting = NSSortDescriptor(key: #keyPath(CoreLogo.updateDate), ascending: false)
        request.sortDescriptors = [sorting]
        request.fetchLimit = 1

        let logos: [CoreLogo]
        do {
            logos = try persistenceController.context.fetch(request)
        } catch {
            return .failure(.fetchFailure(context: error))
        }

        return .success(logos.first?.toAppLogo)
    }

    @discardableResult
    public func replaceLatestUpdated(with args: CoreLogoArgs) -> Result<AppLogo, Errors> {
        let result = getLatestUpdated()
        let latestUpdatedLogo: AppLogo?
        switch result {
        case .failure(let failure):
            return .failure(failure)
        case .success(let success):
            latestUpdatedLogo = success
        }

        if let latestUpdatedLogo {
            return update(logo: latestUpdatedLogo, with: args)
        }

        return create(args)
    }

    private func update(logo: AppLogo, with args: CoreLogoArgs) -> Result<AppLogo, Errors> {
        let context = persistenceController.context
        let predicate = NSPredicate(format: "id = %@", logo.id.nsString)

        let coreLogo: CoreLogo?
        do {
            coreLogo = try CoreLogo.find(by: predicate, from: context)
        } catch {
            return .failure(.fetchFailure(context: error))
        }
        assert(coreLogo != nil, "Core Logo should not be nil now")

        let updatedLogo: CoreLogo?
        do {
            updatedLogo = try coreLogo?.update(with: args)
        } catch {
            return .failure(.createFailure(context: error))
        }
        assert(updatedLogo != nil, "Updated logo should not be nil now")

        return .success(updatedLogo?.toAppLogo ?? logo)
    }

    private func create(_ args: CoreLogoArgs) -> Result<AppLogo, Errors> {
        let context = persistenceController.context

        let logo: CoreLogo
        do {
            logo = try CoreLogo.create(from: args, context: context)
        } catch {
            return .failure(.createFailure(context: error))
        }

        return .success(logo.toAppLogo)
    }
}

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
        configuration.logo = logo
        logo.configuration = configuration

        try context.save()

        return logo
    }
}

extension CoreLogoConfiguration {
    var toAppLogoConfiguration: AppLogoConfiguration {
        AppLogoConfiguration(id: id, cornerRadius: cornerRadius)
    }
}

public struct CoreLogoArgs {
    public let data: Data
    public let configuration: CoreConfigurationArgs

    public init(data: Data, configuration: CoreConfigurationArgs) {
        self.data = data
        self.configuration = configuration
    }
}

public struct CoreConfigurationArgs {
    public let cornerRadius: Double

    public init(cornerRadius: Double) {
        self.cornerRadius = cornerRadius
    }
}

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

public struct AppLogoConfiguration: Identifiable, Hashable {
    public let id: UUID
    public let cornerRadius: Double

    public init(id: UUID, cornerRadius: Double) {
        self.id = id
        self.cornerRadius = cornerRadius
    }
}
