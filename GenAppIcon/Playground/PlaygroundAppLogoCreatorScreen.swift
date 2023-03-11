//
//  PlaygroundAppLogoCreatorScreen.swift
//  GenAppIcon
//
//  Created by Kamaal M Farah on 11/03/2023.
//

#if DEBUG
import SwiftUI
import SalmonUI

struct PlaygroundAppLogoCreatorScreen: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        KScrollableForm {
            KJustStack {
                logoSection
            }
            .padding(.all, 16)
        }
    }

    private var logoSection: some View {
        KSection(header: "Logo") {
            HStack(alignment: .top) {
                viewModel.logoView(size: 150, curvedCornersSize: 16)
            }
        }
    }
}

extension PlaygroundAppLogoCreatorScreen {
    final class ViewModel: ObservableObject {
        func logoView(size: CGFloat, curvedCornersSize: CGFloat) -> some View {
            AppLogo(size: size, curvedCornersSize: curvedCornersSize)
        }
    }
}

struct PlaygroundAppLogoCreatorScreen_Previews: PreviewProvider {
    static var previews: some View {
        PlaygroundAppLogoCreatorScreen()
    }
}
#endif
