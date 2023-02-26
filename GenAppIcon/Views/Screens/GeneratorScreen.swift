//
//  GeneratorScreen.swift
//  GenAppIcon
//
//  Created by Kamaal M Farah on 26/02/2023.
//

import SwiftUI
import FileOpener

struct GeneratorScreen: View {
    @State private var showFileOpener = false

    var body: some View {
        VStack {
            Button(action: { showFileOpener = true }) {
                Text("Upload image")
            }
        }
        .openFile(isPresented: $showFileOpener, contentTypes: [.image]) { content in
            print(content)
        }
    }
}

struct GeneratorScreen_Previews: PreviewProvider {
    static var previews: some View {
        GeneratorScreen()
    }
}
