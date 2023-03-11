//
//  PlaygroundScreen.swift
//  GenAppIcon
//
//  Created by Kamaal M Farah on 11/03/2023.
//

#if DEBUG
import SwiftUI
import SalmonUI

struct PlaygroundScreen: View {
    var body: some View {
        KScrollableForm {
            KSection(header: "Personalization") {
                PlaygroundNavigationLink(title: "App logo creator", desitination: .appLogoCreator)
            }
        }
        .padding(.all, 16)
    }
}

struct PlaygroundScreen_Previews: PreviewProvider {
    static var previews: some View {
        PlaygroundScreen()
    }
}
#endif
