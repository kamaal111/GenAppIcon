//
//  SavePanel.swift
//  GenAppIcon
//
//  Created by Kamaal M Farah on 04/03/2023.
//

import Cocoa

struct SavePanel {
    private init() { }

    static func savePanel(filename: String) async -> (NSApplication.ModalResponse, NSSavePanel) {
        await withCheckedContinuation { continuation in
            save(filename: filename) { result, panel in
                continuation.resume(returning: (result, panel))
            }
        }
    }

    private static func save(
        filename: String,
        beginHandler: @escaping (_ result: NSApplication.ModalResponse, _ panel: NSSavePanel) -> Void
    ) {
        DispatchQueue.main.async {
            let panel = NSSavePanel()
            panel.canCreateDirectories = true
            panel.showsTagField = true
            panel.nameFieldStringValue = filename
            panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
            panel.begin(completionHandler: { result in
                beginHandler(result, panel)
            })
        }
    }
}
