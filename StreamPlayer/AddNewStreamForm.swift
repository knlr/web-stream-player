//
//  AddNewStreamForm.swift
//  StreamPlayer
//
//  Created by Knut on 27/12/2023.
//

import Foundation
import SwiftUI

struct AddNewStreamForm : View {

    @Environment(\.presentationMode) var presentationMode

    @State var name = ""
    @State var url = ""
    @FocusState var focused: Bool
    var body: some View {

        VStack {
            TextField("URL", text: $url)
                .focused($focused)
            TextField("Name", text: $name)
            Button("Add") {

                guard !name.isEmpty, let url = URL(string: url) else { return }
                StreamsRepository.shared.appendStream(Stream(url: url, name: name))
                presentationMode.wrappedValue.dismiss()
            }
        }.onAppear(perform: { focused = true })
    }
}
