//
//  WideButton.swift
//  GenAppIcon
//
//  Created by Kamaal Farah on 05/03/2023.
//

import SwiftUI
import SalmonUI

struct WideButton<Content: View>: View {
    let content: Content
    let action: () -> Void

    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            content
                .foregroundColor(.accentColor)
                // Hack: need the following 2 lines to be fully clickable on macOS
                .ktakeWidthEagerly()
                .background(Color(nsColor: .separatorColor).opacity(0.01))
        }
        .buttonStyle(.plain)
    }
}

struct WideButton_Previews: PreviewProvider {
    static var previews: some View {
        WideButton(action: { }) {
            Text("Button")
        }
    }
}
