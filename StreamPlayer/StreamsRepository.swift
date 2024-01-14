//
//  StreamsRepository.swift
//  StreamPlayer
//
//  Created by Knut on 27/12/2023.
//

import Foundation
import MediaPlayer


internal class StreamsRepository {
 
    internal static let shared = StreamsRepository()
    
    internal var streams: [Stream] {
        
        let streamsData = UserDefaults.standard.data(forKey: userDefaultsKey) ?? Data()
        let streams = (try? PropertyListDecoder().decode([Stream].self, from: streamsData)) ?? []
        if !streamsLoadedOnce {
            
            updateRCCSkipButtons(streams: streams)
            streamsLoadedOnce = true
        }
        return streams
    }
    
    internal func appendStream(_ stream: Stream) {
        
        var streams = self.streams
        streams.append(stream)
        saveStreams(streams)
    }
    
    
    internal func updateStream(at index: Int, stream: Stream) {
        
        var streams = self.streams
        guard index < streams.count else { return }
        streams[index] = stream
        saveStreams(streams)
    }
    
    internal func move(from: IndexSet, to: Int) {
        
        var streams = self.streams
        streams.move(fromOffsets: from, toOffset: to)
        saveStreams(streams)
    }
    
    
    internal func deleteStream(at index: Int) {
        
        var streams = self.streams
        streams.remove(at: index)
        saveStreams(streams)
    }
    
    private let userDefaultsKey = "streams"
    private var streamsLoadedOnce = false
}


private extension StreamsRepository {
    
    func updateRCCSkipButtons(streams: [Stream]){
        
        let rcc = MPRemoteCommandCenter.shared()
        rcc.nextTrackCommand.isEnabled = streams.count > 1
        rcc.previousTrackCommand.isEnabled = streams.count > 1
    }
    
    func saveStreams( _ streams: [Stream]) {
                
        updateRCCSkipButtons(streams: streams)
        UserDefaults.standard.setValue(try! PropertyListEncoder().encode(streams), forKey: userDefaultsKey)
   }
}
