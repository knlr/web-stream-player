//
//  StreamPlayerEngine.swift
//  StreamPlayer
//
//  Created by Knut on 27/12/2023.
//

import Foundation
import AVFoundation
import MediaPlayer
import SwiftData

internal class StreamPlayerEngine : ObservableObject {
        
    internal var modelContext: ModelContext?
    internal enum PlayState {
        case stopped, paused, playing
    }
    private var player = AVPlayer()
    private var audioInitialised = false
    @Published internal private (set) var currentStream: Stream?
    @Published internal private (set) var state: PlayState = .stopped

    
    internal func play(stream: Stream) {
        
        if !audioInitialised {
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playback, mode: .default, options: [.duckOthers, .allowBluetooth, .allowAirPlay, .allowBluetoothA2DP])
                try session.setActive(true)
            } catch {
                print(#file, #line, error)
            }
            let rcc = MPRemoteCommandCenter.shared()
            rcc.nextTrackCommand.addTarget(handler: self.onNextTrackCommand(event:))
            rcc.previousTrackCommand.addTarget(handler: self.onPreviousTrackCommand(event:))
            rcc.togglePlayPauseCommand.addTarget(handler: self.togglePlayPauseCommand(event:))
            audioInitialised = true
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: stream.name]
        player.replaceCurrentItem(with: AVPlayerItem(url: stream.url))
        player.play()
        state = .playing
        currentStream = stream
    }
    
    internal func playPauseToggle() {
        switch state {
        case .paused:
            player.play()
            state = .playing
            try? AVAudioSession.sharedInstance().setActive(true)
        case .playing:
            player.pause()
            try? AVAudioSession.sharedInstance().setActive(false)
            state = .paused
        default: ()
        }
    }
        
    
    internal func skipForward() {
        
        guard let currentStream = currentStream, streams.count > 1,
        let index = streams.firstIndex(of: currentStream) else {
            return
        }
        play(stream: streams[(index + 1) % streams.count])
    }
    
    
    internal func skipBackward() {
        
        guard let currentStream = currentStream, streams.count > 1,
        let index = streams.firstIndex(of: currentStream) else {
            return
        }
        play(stream: streams[index == 0 ? streams.count - 1 : index - 1])
    }
}

private extension StreamPlayerEngine {
    
    var streams: [Stream] { (try? modelContext?.fetch(FetchDescriptor<Stream>())) ?? [] }
    
    func onNextTrackCommand(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
     
        guard let currentStream = currentStream else {
            return .noActionableNowPlayingItem
        }
        guard let index = streams.firstIndex(of: currentStream) else {         
            return .noSuchContent
        }
        play(stream: streams[(index + 1) % streams.count])
        return .success
    }
    
    func onPreviousTrackCommand(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        
        guard let currentStream = currentStream else {
            return .noActionableNowPlayingItem
        }
        guard var index = streams.firstIndex(of: currentStream) else {
            return .noSuchContent
        }
        index = index == 0 ? streams.count - 1 : index - 1
        play(stream: streams[index])
        return .success
    }
    
    
    func togglePlayPauseCommand(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
     
        guard currentStream != nil else {
            return .noActionableNowPlayingItem
        }
        playPauseToggle()
        return .success
    }
}
