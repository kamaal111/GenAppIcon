//
//  Shell.swift
//  GenAppIcon
//
//  Created by Kamaal M Farah on 04/03/2023.
//

import Foundation

struct Shell {
    private init() { }

    static func zsh(_ command: String) -> String {
        shell("/bin/zsh", command)
    }

    private static func shell(_ launchPath: String, _ command: String) -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = launchPath
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!

        return output
    }

    @discardableResult
    static func runAppIconGenerator(input: Data, output: URL) throws -> String {
        let fileManager = FileManager.default
        let temporaryFileURL = fileManager.temporaryDirectory.appending(component: "\(UUID().uuidString).png")
        try input.write(to: temporaryFileURL)

        defer { try? cleanUp(fileURL: temporaryFileURL) }

        let bundleResourceURL = Bundle.main.resourceURL!
        let appIconGeneratorName = "app-icon-generator"
        let appIconGenerator = try fileManager.findDirectoryOrFile(
            inDirectory: bundleResourceURL,
            searchPath: appIconGeneratorName
        )!
        let appIconGeneratorPath = appIconGenerator
            .relativePath
            .replacingOccurrences(of: " ", with: "\\ \\")
            .replacingOccurrences(of: ")", with: "\\)")
        let command = "\(appIconGeneratorPath) -o \(output.relativePath) -i \(temporaryFileURL.relativePath) -v"
        return Shell.zsh(command)
    }

    private static func cleanUp(fileURL: URL) throws {
        try FileManager.default.removeItem(at: fileURL)
    }
}
