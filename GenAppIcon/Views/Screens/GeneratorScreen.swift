//
//  GeneratorScreen.swift
//  GenAppIcon
//
//  Created by Kamaal M Farah on 26/02/2023.
//

import SwiftUI
import Logster
import Backend
import Combine
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
        ScrollView {
            VStack(alignment: .center, spacing: 0) {
                WideButton(action: { viewModel.openFileOpener() }) {
                    VStack {
                        Text(GALocales.getText(.UPLOAD_IMAGE))
                            .bold()
                        Text(GALocales.getText(.DRAG_AND_DROP_HINT))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .disabled(viewModel.loading)
                WideButton(action: onGenerateAppIconsClick) {
                    Text(GALocales.getText(.GENERATE_APP_ICONS))
                        .bold()
                }
                .disabled(viewModel.generateAppIconIsDisabled)
                .padding(.vertical, 8)
                if let image = viewModel.image {
                    viewModel.styledImage(size: 200, image: image)
                        .padding(.vertical, 8)
                    HStack {
                        Stepper(
                            GALocales.getText(
                                .CORNER_RADIUS_STEPPER_LABEL,
                                with: [Int(viewModel.logoCornerRadius).nsNumber]),
                            value: $viewModel.logoCornerRadius)
                        .disabled(!viewModel.logoCornerRadiusIsEnabled)
                        Toggle("", isOn: $viewModel.logoCornerRadiusIsEnabled)
                            .labelsHidden()
                    }
                    .padding(.vertical, 8)
                    HStack {
                        Text(GALocales.getText(
                            .BRIGHTNESS_SLIDER_LABEL,
                            with: [viewModel.imageBrightnessPercentage]))
                        .frame(width: 120)
                        .padding(.top, -4)
                        Slider(value: $viewModel.logoBrightness, in: -1...1, step: 0.1)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                }
            }
            .padding(16)
        }
        .ktakeSizeEagerly(alignment: .top)
        .openFile(isPresented: $viewModel.showFileOpener, contentTypes: [.image], onFileOpen: onFileOpened)
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
            let status: SavePanelStatus
            switch result {
            case .failure(let failure):
                popperUpManager.showPopup(style: failure.popupStyle, timeout: 3)
                return
            case .success(let success):
                status = success
            }

            guard status == .ok else { return }

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
        @Published var logoCornerRadius: CGFloat = 0
        @Published var logoBrightness: CGFloat = 0
        @Published var logoCornerRadiusIsEnabled = true

        private let backend = Backend.shared
        private var logoCornerRadiusSetterSubscription = Set<AnyCancellable>()
        private var logoBrightnessSetterSubscription = Set<AnyCancellable>()
        private var debouncedLogoCornerRadius: CGFloat = 0 {
            didSet { debouncedLogoCornerRadiusDidSet() }
        }
        private var debounceLogoBrightness: CGFloat = 0 {
            didSet { debouncedLogoBrightnessDidSet() }
        }
        private var logoConfigurationReference: AppLogoConfiguration?

        init() {
            if let latestUpdatedLogoResult = try? backend.logos.getLatestUpdated().get() {
                Task {
                    await setImageData(latestUpdatedLogoResult.data)
                    await setLogoConfiguration(latestUpdatedLogoResult.configuration)
                }
            }

            $logoBrightness
                .debounce(for: .seconds(3), scheduler: DispatchQueue.global())
                .sink(receiveValue: { [weak self] value in
                    self?.debounceLogoBrightness = value
                })
                .store(in: &logoBrightnessSetterSubscription)

            $logoCornerRadius
                .debounce(for: .seconds(3), scheduler: DispatchQueue.global())
                .sink(receiveValue: { [weak self] value in
                    self?.debouncedLogoCornerRadius = value
                })
                .store(in: &logoCornerRadiusSetterSubscription)
        }

        enum Errors: Error {
            case generateAppIconFailed(context: Error?)
            case failedToSaveAppIcon
            case fileNotFound
            case fileCouldNotBeRead(context: Error?)
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

        var imageBrightnessPercentage: NSNumber {
            Int(logoBrightness * 100).nsNumber
        }

        var image: NSImage? {
            guard let imageData else { return nil }

            return NSImage(data: imageData)
        }

        var previewCornerRadius: CGFloat {
            guard let imageSize else { return 0 }

            let shortestEnd = min(imageSize.width, imageSize.height)

            return logoCornerRadius / (shortestEnd / 200)
        }

        var generateAppIconIsDisabled: Bool {
            image == nil || loading
        }

        func styledImage(size: CGFloat, image: NSImage) -> some View {
            Image(nsImage: image)
                .size(.squared(size))
                .brightness(logoBrightness)
                .cornerRadius(logoCornerRadiusIsEnabled ? logoCornerRadius : 0)
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

            let replaceLatestUpdatedResult = backend.logos.replaceLatestUpdated(
                with: CoreLogoArgs(
                    data: supportedImage,
                    configuration: CoreConfigurationArgs(cornerRadius: logoCornerRadius, brightness: logoBrightness)))
            switch replaceLatestUpdatedResult {
            case .failure(let failure):
                logger.error(label: "Failed to replace last updated logo", error: failure)
                assertionFailure("Failed to replace last updated logo")
                return .failure(.fileCouldNotBeRead(context: failure))
            case .success(let success):
                Task {
                    await setImageData(success.data)
                    await setLogoConfiguration(success.configuration)
                }
            }

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

                guard let content else { return .success(()) }

                logger.info("Opened file successfully")

                let replaceLatestUpdatedResult = backend.logos.replaceLatestUpdated(
                    with: CoreLogoArgs(
                        data: content,
                        configuration: CoreConfigurationArgs(
                            cornerRadius: logoCornerRadius,
                            brightness: logoBrightness)))
                switch replaceLatestUpdatedResult {
                case .failure(let failure):
                    logger.error(label: "Failed to replace last updated logo", error: failure)
                    assertionFailure("Failed to replace last updated logo")
                    return .failure(.fileCouldNotBeRead(context: failure))
                case .success(let success):
                    await setImageData(success.data)
                    await setLogoConfiguration(success.configuration)
                }

                return .success(())
            })
        }

        func generateAppIcons() async -> Result<SavePanelStatus, Errors> {
            await withLoading(function: {
                guard let image, let imageSize else {
                    assertionFailure("These values should have been filled")
                    return .success(.cancel)
                }

                let imageView = styledImage(size: min(imageSize.width, imageSize.height), image: image)

                return await AppIconGenerator.generate(from: imageView)
                    .mapError(handleAppIconGeneratorError)
            })
        }

        @MainActor
        func openFileOpener() {
            showFileOpener = true
        }

        private var imageSize: CGSize? {
            image?.size
        }

        @MainActor
        private func setLogoCornerRadius(_ value: CGFloat) {
            guard logoCornerRadius != value else { return }

            self.logoCornerRadius = value
        }

        @MainActor
        private func setLogoBrightness(_ value: CGFloat) {
            guard logoBrightness != value else { return }

            self.logoBrightness = value
        }

        private func setLogoConfiguration(_ configuration: AppLogoConfiguration) async {
            await setLogoCornerRadius(configuration.cornerRadius)
            await setLogoBrightness(configuration.brightness)
            logoConfigurationReference = configuration
        }

        private func debouncedLogoCornerRadiusDidSet() {
            guard let logoConfigurationReference,
                  logoConfigurationReference.cornerRadius != debouncedLogoCornerRadius else { return }

            let result = backend.logos.updateConfiguration(
                of: logoConfigurationReference,
                with: CoreConfigurationArgs(cornerRadius: debouncedLogoCornerRadius, brightness: logoBrightness))
            let updatedConfiguration: AppLogoConfiguration
            switch result {
            case .failure(let failure):
                logger.error(label: "Failed to update logo configuration", error: failure)
                assertionFailure("Failed to update logo configuration")
                return
            case .success(let success):
                updatedConfiguration = success
            }

            self.logoConfigurationReference = updatedConfiguration
            logger.info("Updated logo configuration")
        }

        private func debouncedLogoBrightnessDidSet() {
            guard let logoConfigurationReference,
                  logoConfigurationReference.brightness != debounceLogoBrightness else { return }

            let result = backend.logos.updateConfiguration(
                of: logoConfigurationReference,
                with: CoreConfigurationArgs(cornerRadius: logoCornerRadius, brightness: debounceLogoBrightness))
            let updatedConfiguration: AppLogoConfiguration
            switch result {
            case .failure(let failure):
                logger.error(label: "Failed to update logo configuration", error: failure)
                assertionFailure("Failed to update logo configuration")
                return
            case .success(let success):
                updatedConfiguration = success
            }

            self.logoConfigurationReference = updatedConfiguration
            logger.info("Updated logo configuration")
        }

        @MainActor
        private func setImageData(_ imageData: Data) {
            withAnimation {
                self.imageData = imageData
            }
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
                return .fileCouldNotBeRead(context: context)
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
