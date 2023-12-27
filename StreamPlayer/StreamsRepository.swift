//
//  StreamsRepository.swift
//  StreamPlayer
//
//  Created by Knut on 27/12/2023.
//

import Foundation

internal class StreamsRepository {
    
    internal static let shared = StreamsRepository()
    
    internal var streams: [Stream] {
        
        let streamsData = UserDefaults.standard.data(forKey: userDefaultsKey) ?? Data()
        return (try? PropertyListDecoder().decode([Stream].self, from: streamsData)) ?? []
    }
    
    internal func appendStream(_ stream: Stream) {
        
        var streams = self.streams
        streams.append(stream)
        saveStreams(streams)
    }
    
    
    internal func deleteStream(at index: Int) {
        
        var streams = self.streams
        streams.remove(at: index)
        saveStreams(streams)
    }
    
    private let userDefaultsKey = "streams"
}


private extension StreamsRepository {
    
    func saveStreams( _ streams: [Stream]) {
        
        UserDefaults.standard.setValue(try! PropertyListEncoder().encode(streams), forKey: userDefaultsKey)
   }
}
