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

    public func updateConfiguration(of configuration: AppLogoConfiguration, with args: CoreConfigurationArgs) -> Result<AppLogoConfiguration, Errors> {
        let context = persistenceController.context
        let predicate = NSPredicate(format: "id = %@", configuration.id.nsString)

        let coreConfiguration: CoreLogoConfiguration?
        do {
            coreConfiguration = try CoreLogoConfiguration.find(by: predicate, from: context)
        } catch {
            return .failure(.fetchFailure(context: error))
        }
        assert(coreConfiguration != nil, "Configuration should not be nil now")

        let updatedConfiguration: CoreLogoConfiguration?
        do {
            updatedConfiguration = try coreConfiguration?.update(with: args)
        } catch {
            return .failure(.createFailure(context: error))
        }
        assert(updatedConfiguration != nil, "Configuration should not be nil now")

        return .success(updatedConfiguration?.toAppLogoConfiguration ?? configuration)
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
