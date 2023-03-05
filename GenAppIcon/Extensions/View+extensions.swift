//
//  View+extensions.swift
//  GenAppIcon
//
//  Created by Kamaal Farah on 05/03/2023.
//

import SwiftUI

extension View {
    func snapshot() -> NSImage? {
        let controller = NSHostingController(rootView: self)
        let view = controller.view

        let targetSize = view.intrinsicContentSize
        let targetPoint = CGPoint(x: -(targetSize.width / 2), y: -(targetSize.height / 2))
        let targetBounds = CGRect(origin: targetPoint, size: targetSize)

        guard let bitmapRep = view.bitmapImageRepForCachingDisplay(in: targetBounds) else { return nil }

        bitmapRep.size = targetSize
        view.cacheDisplay(in: targetBounds, to: bitmapRep)

        let image = NSImage(size: targetSize)
        image.addRepresentation(bitmapRep)

        return image
    }
}
