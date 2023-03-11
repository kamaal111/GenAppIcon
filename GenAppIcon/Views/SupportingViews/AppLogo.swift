//
//  AppLogo.swift
//  GenAppIcon
//
//  Created by Kamaal M Farah on 11/03/2023.
//

import SwiftUI
import ShrimpExtensions

struct AppLogo: View {
    let size: CGFloat
    let curvedCornersSize: CGFloat?

    var body: some View {
        ZStack {
            Text("Logo")
        }
        .frame(width: size, height: size)
        .cornerRadius(curvedCornersSize ?? 0)
    }
}

struct AppLogo_Previews: PreviewProvider {
    static var previews: some View {
        AppLogo(size: 200, curvedCornersSize: 16)
    }
}
