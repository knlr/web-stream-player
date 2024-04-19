//
//  Item.swift
//  StreamPlayer
//
//  Created by Knut on 08/04/2024.
//

import Foundation
import SwiftData

@Model
final class Stream {
    init(url: URL, name: String) {
        self.url = url
        self.name = name
    }
    var url: URL
    var name: String
}

extension Stream : Identifiable {
    var id: String {
        return url.absoluteString
    }
}

@Model
final class StreamList {
    init(streams: [Stream]) {
        self.streams = streams
    }
    var streams: [Stream]
}
