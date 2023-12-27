//
//  Stream.swift
//  StreamPlayer
//
//  Created by Knut on 27/12/2023.
//

import Foundation


struct Stream : Hashable, Codable {
    let url: URL
    let name: String
}

extension Stream : Identifiable {
    var id: String {
        return url.absoluteString
    }
}
