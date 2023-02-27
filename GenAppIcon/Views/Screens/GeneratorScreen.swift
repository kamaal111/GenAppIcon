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
        }
        .openFile(isPresented: $viewModel.showFileOpener, contentTypes: [.image], onFileOpen: onFileOpened)
    }

    private func onFileOpened(_ result: Result<Data?, FileOpenerErrors>) {
        let content: Data?
        switch result {
        case .failure(let failure):
            handleFileOpenFailure(failure)
            return
        case .success(let success):
            content = success
        }

        Task {
            await viewModel.handleContentFromOpenedFile(content)
        }
    }

    private func handleFileOpenFailure(_ failure: FileOpenerErrors) {
        let style: PopperUpStyles
        switch failure {
        case .fileNotFound:
            style = .bottom(title: GALocales.getText(.IMAGE_NOT_FOUND), type: .error, description: .none)
            logger.error("Failed to find file")
            assertionFailure("Images should always be found")
        case .fileCouldNotBeRead(context: let context):
            style = .bottom(
                title: GALocales.getText(.UNSUPPORTED_IMAGE),
                type: .error,
                description: GALocales.getText(.UNSUPPORTED_IMAGE_DESCRIPTION))
            logger.error(label: "Failed to read file", error: context)
            assertionFailure("Unsupported file")
        case .notAllowedToReadFile:
            style = .bottom(
                title: GALocales.getText(.IMAGE_NOT_ALLOWED),
                type: .error,
                description: GALocales.getText(.IMAGE_NOT_ALLOWED_DESCRIPTION))
            logger.warning("Secure image loaded")
        }
        popperUpManager.showPopup(style: style, timeout: 3)
    }
}

extension GeneratorScreen {
    final class ViewModel: ObservableObject {
        @Published var showFileOpener = false
        @Published private(set) var image: NSImage?

        func handleContentFromOpenedFile(_ content: Data?) async {
            guard let content, let image = NSImage(data: content) else { return }

            await setImage(image)
        }

        @MainActor
        func openFileOpener() {
            showFileOpener = true
        }

        @MainActor
        func setImage(_ image: NSImage) {
            self.image = image
        }
    }
}

struct GeneratorScreen_Previews: PreviewProvider {
    static var previews: some View {
        GeneratorScreen()
    }
}
