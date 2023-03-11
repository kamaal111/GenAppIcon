//
//  SavePanelStatus.swift
//  
//
//  Created by Kamaal M Farah on 11/03/2023.
//

import Cocoa

public enum SavePanelStatus: Equatable {
    case ok
    case cancel
    case unknown(response: NSApplication.ModalResponse)
}
