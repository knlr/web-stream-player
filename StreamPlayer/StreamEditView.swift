//
//  StreamEditView.swift
//  StreamPlayer
//
//  Created by Knut on 08/04/2024.
//

import SwiftUI

struct StreamEditView : View {
    
    internal var okAction: (Stream) -> Void = { _ in }
    @State internal var name: String = ""
    @State internal var url: String = ""
    @State internal var actionLabel: String = ""
    
    var body : some View {
        
        TextField("Name", text: $name)
        TextField("URL", text: $url)
        
        Button (action: {
            if let url = URL(string: url), !name.isEmpty {
                okAction(Stream(url: url, name: name))
            }
        }, label: {
            Text(actionLabel)
        })
        Button(action : {},
               label: {
            Text("Cancel")
        })
    }
}

#Preview {
    StreamEditView()
}
