//
//  FileManager+extensions.swift
//  
//
//  Created by Kamaal M Farah on 04/03/2023.
//

import Foundation
import ShrimpExtensions

extension FileManager {
    func findDirectoryOrFile(inDirectory directory: URL, searchPath: String) throws -> URL? {
        try contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [])
            .find(by: \.lastPathComponent, is: searchPath)
    }
}
