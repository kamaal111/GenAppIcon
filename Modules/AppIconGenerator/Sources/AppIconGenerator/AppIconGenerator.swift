//
//  AppIconGenerator.swift
//
//
//  Created by Kamaal M Farah on 04/03/2023.
//

import SwiftUI
import ShrimpExtensions

public struct AppIconGenerator {
    private init() { }

    public enum Errors: Error {
        case conversionFailure
        case generateAppIconFailure(context: ShellErrors?)
        case failedToSaveAppIcon
    }

    public static func generate(from view: some View) async -> Result<SavePanelStatus, Errors> {
        let data = await ImageRenderer(content: view)
            .nsImage?
            .tiffRepresentation

        guard let data else { return .failure(.conversionFailure) }

        return await generate(data)
    }

    private static func generate(_ appIconData: Data) async -> Result<SavePanelStatus, Errors> {
        guard let pngRepresentation = NSBitmapImageRep(data: appIconData)?.representation(using: .png, properties: [:])
        else { return .failure(.conversionFailure) }

        let fileManager = FileManager.default
        let temporaryDirectory = fileManager.temporaryDirectory
        let appIconScriptResult = Shell.runAppIconGenerator(input: pngRepresentation, output: temporaryDirectory)
            .mapError({ error in Errors.generateAppIconFailure(context: error) })
        let output: String
        switch appIconScriptResult {
        case .failure(let failure):
            return .failure(failure)
        case .success(let success):
            output = success
        }
        guard output.splitLines.last?.hasPrefix("done creating icons") == true else {
            return .failure(.generateAppIconFailure(context: .standardError(message: output)))
        }

        let iconSetName = "AppIcon.appiconset"
        let iconSetURL = try! fileManager.findDirectoryOrFile(
            inDirectory: temporaryDirectory,
            searchPath: iconSetName
        )!
        defer { try? fileManager.removeItem(at: iconSetURL) }

        let (savePanelResult, panel) = await SavePanel.savePanel(filename: iconSetName)
        guard savePanelResult == .ok else { return .success(savePanelResult) }

        guard let saveURL = await panel.url else { return .failure(.failedToSaveAppIcon) }

        if fileManager.fileExists(atPath: saveURL.path) {
            try? fileManager.removeItem(at: saveURL)
        }

        do {
            try fileManager.moveItem(at: iconSetURL, to: saveURL)
        } catch {
            return .failure(.failedToSaveAppIcon)
        }

        return .success(savePanelResult)
    }
}
