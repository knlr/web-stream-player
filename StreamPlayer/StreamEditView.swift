//
//  StreamEditView.swift
//  StreamPlayer
//
//  Created by Knut on 08/04/2024.
//

import SwiftUI
import SwiftData

struct StreamEditView : View {
    
    internal var okAction: (Stream) -> Void = { _ in }
    @State internal var name: String = ""
    @State internal var url: String = ""
    @State internal var actionLabel: String = ""
    @Query private var streamList: [StreamList]

    var body : some View {
        
        TextField("Name", text: $name)
        TextField("URL", text: $url)
        

        Button(role: .cancel, action : {},
               label: {
            Text("Cancel")
        })
        
        Button (action: {
            if let url = URL(string: url), !name.isEmpty {
                okAction(Stream(url: url, name: name))
            }
        }, label: {
            Text(actionLabel)
        }).disabled(okButtonDisabled)
    }
    
    
    private var okButtonDisabled: Bool {
        
        return !url.isValidWebURL || streamList[0].streams.contains(where: { $0.url.absoluteString == url})
    }
}

#Preview {
    StreamEditView()
}
