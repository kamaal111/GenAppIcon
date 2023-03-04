//
//  GeneratorScreen.swift
//  GenAppIcon
//
//  Created by Kamaal M Farah on 26/02/2023.
//

import SwiftUI
import Logster
import SalmonUI
import PopperUp
import GALocales
import FileOpener
import AppIconGenerator
import ShrimpExtensions

private let logger = Logster(from: GeneratorScreen.self)

struct GeneratorScreen: View {
    @EnvironmentObject private var popperUpManager: PopperUpManager

    @StateObject private var viewModel = ViewModel()

    var body: some View {
        VStack {
            if let image = viewModel.image {
                Image(nsImage: image)
                    .size(.squared(200))
                    .cornerRadius(16)
            }
            Button(action: { viewModel.openFileOpener() }) {
                Text(GALocales.getText(.UPLOAD_IMAGE))
                    .bold()
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.loading)
            Button(action: onGenerateAppIconsClick) {
                Text(GALocales.getText(.GENERATE_APP_ICONS))
                    .bold()
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.generateAppIconIsDisabled)
        }
        .openFile(isPresented: $viewModel.showFileOpener, contentTypes: [.image], onFileOpen: onFileOpened)
        .ktakeSizeEagerly()
        .dropDestination(action: handleDropDestination)
    }

    private func handleDropDestination(_ items: [Data], _ location: CGPoint) -> Bool {
        let result = viewModel.handleDroppedFiles(items)
        switch result {
        case .failure(let failure):
            popperUpManager.showPopup(style: failure.popupStyle, timeout: 3)
            return false
        case .success:
            break
        }

        return true
    }

    private func onFileOpened(_ result: Result<Data?, FileOpenerErrors>) {
        Task {
            let result = await viewModel.handleFileOpened(result)
            switch result {
            case .failure(let failure):
                popperUpManager.showPopup(style: failure.popupStyle, timeout: 3)
            case .success:
                break
            }
        }
    }

    private func onGenerateAppIconsClick() {
        Task {
            let result = await viewModel.generateAppIcons()
            switch result {
            case .failure(let failure):
                popperUpManager.showPopup(style: failure.popupStyle, timeout: 3)
                return
            case .success:
                break
            }

            logger.info("Successfully generated app icons")
            popperUpManager.showPopup(
                style: .bottom(
                    title: GALocales.getText(.SUCCESSFULL_APP_ICON_GENERATED),
                    type: .success,
                    description: .none),
                timeout: 3)
        }
    }
}

extension GeneratorScreen {
    final class ViewModel: ObservableObject {
        @Published var showFileOpener = false
        @Published private var imageData: Data?
        @Published private(set) var loading = false

        private let quickStorage = QuickStorage()

        init() {
            if let imageData = quickStorage.lastUploadedLogo {
                Task { await setImageData(imageData) }
            }
        }

        enum Errors: Error {
            case generateAppIconFailed(context: Error?)
            case failedToSaveAppIcon
            case fileNotFound
            case fileCouldNotBeRead
            case notAllowedToReadFile
            case unsupporedFileFormat

            var popupStyle: PopperUpStyles {
                switch self {
                case .generateAppIconFailed:
                    return .bottom(
                        title: GALocales.getText(.FAILED_TO_GENERATE_APP_ICON),
                        type: .error,
                        description: .none)
                case .failedToSaveAppIcon:
                    return .bottom(title: GALocales.getText(.FAILED_TO_SAVE_APP_ICON), type: .error, description: .none)
                case .fileNotFound:
                    return .bottom(title: GALocales.getText(.IMAGE_NOT_FOUND), type: .error, description: .none)
                case .fileCouldNotBeRead:
                    return .bottom(
                        title: GALocales.getText(.UNSUPPORTED_IMAGE),
                        type: .error,
                        description: GALocales.getText(.UNSUPPORTED_IMAGE_DESCRIPTION))
                case .notAllowedToReadFile:
                    return .bottom(
                        title: GALocales.getText(.IMAGE_NOT_ALLOWED),
                        type: .error,
                        description: GALocales.getText(.IMAGE_NOT_ALLOWED_DESCRIPTION))
                case .unsupporedFileFormat:
                    return .bottom(
                        title: GALocales.getText(.FILE_FORMAT_NOT_SUPPORTED),
                        type: .warning,
                        description: .none)
                }
            }
        }

        var image: NSImage? {
            guard let imageData else { return nil }

            return NSImage(data: imageData)
        }

        var generateAppIconIsDisabled: Bool {
            image == nil || loading
        }

        func handleDroppedFiles(_ filesContent: [Data]) -> Result<Void, Errors> {
            let supportedImage = filesContent
                .first(where: {
                    NSBitmapImageRep(data: $0)?.representation(using: .png, properties: [:]) != nil
                })
            guard let supportedImage else {
                logger.warning("Unsupported file provided")
                return .failure(.unsupporedFileFormat)
            }

            logger.info("Dropped file successfully")
            Task { await setImageData(supportedImage) }
            return .success(())
        }

        func handleFileOpened(_ result: Result<Data?, FileOpenerErrors>) async -> Result<Void, Errors> {
            await withLoading(function: {
                let result = result
                    .mapError(handleFileOpenFailure)
                let content: Data?
                switch result {
                case .failure(let failure):
                    return .failure(failure)
                case .success(let success):
                    content = success
                }

                guard let content else { return .failure(.fileCouldNotBeRead) }

                logger.info("Opened file successfully")
                await setImageData(content)
                return .success(())
            })
        }

        func generateAppIcons() async -> Result<Void, Errors> {
            await withLoading(function: {
                await AppIconGenerator.generate(imageData!)
            })
            .mapError(handleAppIconGeneratorError)
        }

        @MainActor
        func openFileOpener() {
            showFileOpener = true
        }

        @MainActor
        private func setImageData(_ imageData: Data) {
            self.imageData = imageData
            quickStorage.lastUploadedLogo = imageData
        }

        @MainActor
        private func setLoading(_ state: Bool) {
            self.loading = state
        }

        private func withLoading<T>(function: () async -> T) async -> T {
            await setLoading(true)
            let result = await function()
            await setLoading(false)
            return result
        }

        private func handleAppIconGeneratorError(_ error: AppIconGenerator.Errors) -> Errors {
            switch error {
            case .conversionFailure:
                logger.error("Conversion failure while generating app icon")
                assertionFailure("Conversion failure while generating app icon")
                return .generateAppIconFailed(context: error)
            case .generateAppIconFailure(let context):
                let logMessage = "Failed to generate app icon"
                if let context {
                    logger.error(label: logMessage, error: context)
                } else {
                    logger.error(logMessage)
                }
                assertionFailure(logMessage)
                return .generateAppIconFailed(context: context)
            case .failedToSaveAppIcon:
                logger.error("Failed to save app icon")
                assertionFailure("Failed to save app icon")
                return .failedToSaveAppIcon
            }
        }

        private func handleFileOpenFailure(_ failure: FileOpenerErrors) -> Errors {
            switch failure {
            case .fileNotFound:
                logger.error("Failed to find file")
                assertionFailure("Images should always be found")
                return .fileNotFound
            case .fileCouldNotBeRead(context: let context):
                logger.error(label: "Failed to read file", error: context)
                assertionFailure("Unsupported file")
                return .fileCouldNotBeRead
            case .notAllowedToReadFile:
                logger.warning("Secure image loaded")
                return .notAllowedToReadFile
            }
        }
    }
}

struct GeneratorScreen_Previews: PreviewProvider {
    static var previews: some View {
        GeneratorScreen()
    }
}
