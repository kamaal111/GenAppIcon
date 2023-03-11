//
//  PlaygroundNavigationLink.swift
//  GenAppIcon
//
//  Created by Kamaal M Farah on 11/03/2023.
//

#if DEBUG
import SwiftUI
import SalmonUI
import BetterNavigation

struct PlaygroundNavigationLink: View {
    let title: String
    let desitination: Screens

    var body: some View {
        StackNavigationLink(
            destination: desitination,
            nextView: { screen in MainView(screen: screen)}) {
                HStack {
                    Text(title)
                        .foregroundColor(.accentColor)
                    Spacer()
                    #if os(macOS)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                    #endif
                }
                .ktakeWidthEagerly()
                .background(Color(nsColor: .separatorColor).opacity(0.01))
            }
            .buttonStyle(.plain)
    }
}

struct PlaygroundNavigationLink_Previews: PreviewProvider {
    static var previews: some View {
        PlaygroundNavigationLink(title: "Link", desitination: .appLogoCreator)
    }
}
#endif
