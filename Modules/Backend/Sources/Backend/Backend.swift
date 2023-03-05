//
//  Backend.swift
//
//
//  Created by Kamaal Farah on 05/03/2023.
//

public class Backend {
    public let logos: LogosClient

    private init(preview: Bool) {
        self.logos = LogosClient(preview: preview)
    }

    public static let shared = Backend(preview: false)

    public static let preview = Backend(preview: true)
}
