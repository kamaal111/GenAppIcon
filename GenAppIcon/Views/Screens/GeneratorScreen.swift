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
            Button(action: { Task { await viewModel.generateAppIcons() } }) {
                Text(GALocales.getText(.GENERATE_APP_ICONS))
                    .bold()
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.generateAppIconIsDisabled)
        }
        .openFile(isPresented: $viewModel.showFileOpener, contentTypes: [.image], onFileOpen: onFileOpened)
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
}

extension GeneratorScreen {
    final class ViewModel: ObservableObject {
        @Published var showFileOpener = false
        @Published private var imageData: Data?

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
                }
            }
        }

        var image: NSImage? {
            guard let imageData else { return nil }

            return NSImage(data: imageData)
        }

        var generateAppIconIsDisabled: Bool {
            image == nil
        }

        func handleFileOpened(_ result: Result<Data?, FileOpenerErrors>) async -> Result<Void, Errors> {
            let content: Data?
            switch result {
            case .failure(let failure):
                return .failure(handleFileOpenFailure(failure))
            case .success(let success):
                content = success
            }

            guard let content else { return .failure(.fileCouldNotBeRead) }

            await setImageData(content)
            return .success(())
        }

        func generateAppIcons() async -> Result<Void, Errors> {
            guard let bitmapImage = NSBitmapImageRep(data: imageData!),
                  let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
                logger.error("Failed to get PNG representation from image")
                assertionFailure("Failed to get PNG representation from image")
                return .failure(.fileCouldNotBeRead)
            }

            let fileManager = FileManager.default
            let temporaryDirectory = fileManager.temporaryDirectory
            let output: String
            do {
                output = try Shell.runAppIconGenerator(input: pngData, output: temporaryDirectory)
            } catch {
                logger.error(label: "Failed to generate app icon", error: error)
                assertionFailure("Failed to generate app icon")
                return .failure(.generateAppIconFailed(context: error))
            }
            guard let outputMessage = output.splitLines.last, outputMessage.hasPrefix("done creating icons") else {
                logger.error("Failure message in output; \(output)")
                assertionFailure("Failure message in output; \(output)")
                return .failure(.generateAppIconFailed(context: .none))
            }
            logger.info("Output of generate app icon script; \(outputMessage)")

            let iconSetName = "AppIcon.appiconset"
            let iconSetURL = try! fileManager.findDirectoryOrFile(
                inDirectory: temporaryDirectory,
                searchPath: iconSetName
            )!
            defer { try? fileManager.removeItem(at: iconSetURL) }

            let (savePanelResult, panel) = await SavePanel.savePanel(filename: iconSetName)
            guard savePanelResult == .OK else {
                logger.warning("Failed to get result from save panel with status; \(savePanelResult)")
                return .success(())
            }

            guard let saveURL = await panel.url else {
                logger.error("Failed to get save URL")
                assertionFailure("Failed to get save URL")
                return .failure(.failedToSaveAppIcon)
            }

            if fileManager.fileExists(atPath: saveURL.path) {
                try? fileManager.removeItem(at: saveURL)
            }

            do {
                try fileManager.moveItem(at: iconSetURL, to: saveURL)
            } catch {
                logger.error(label: "Failed to save icon at the given location", error: error)
                assertionFailure("Failed to save icon at the given location")
                return .failure(.failedToSaveAppIcon)
            }

            return .success(())
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
