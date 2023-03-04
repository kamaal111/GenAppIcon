//
//  ShellErrors.swift
//  
//
//  Created by Kamaal M Farah on 04/03/2023.
//

import Foundation

public enum PipeTypes {
    case output
    case error
}

public enum ShellErrors: Error {
    case standardError(message: String)
    case readPipeError(context: Error, pipe: PipeTypes)
}
