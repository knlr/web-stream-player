//
//  ContentView.swift
//  StreamPlayer
//
//  Created by Knut Lorenzen on 23/10/2022.
//

import SwiftUI
import AVFoundation
import MediaPlayer

struct Stream : Hashable, Codable {
    let url: URL
    let name: String
}

extension Stream : Identifiable {
    var id: String {
        return url.absoluteString
    }
}

struct AddNewStreamForm : View {

    @Environment(\.presentationMode) var presentationMode

    @State var name = ""
    @State var url = ""
    var body: some View {

        VStack {
            TextField("URL", text: $url)
            TextField("Name", text: $name)
            Button("Add") {

                guard !name.isEmpty, let url = URL(string: url) else { return }
                let streamsData = UserDefaults.standard.data(forKey: "streams") ?? Data()
                var streamsArray = (try? PropertyListDecoder().decode([Stream].self, from: streamsData)) ?? []
                streamsArray.append(Stream(url: url, name: name))
                UserDefaults.standard.setValue(try! PropertyListEncoder().encode(streamsArray), forKey: "streams")
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}


struct ContentView: View {

    private enum PlayState {
        case stopped, paused, playing
    }
    @State private var playState: PlayState = .stopped
    @State private var streams: [Stream] = []
    private var player = AVPlayer()
    @State private var sheetIsPresented = false
    @State private var selection: Stream?
    @State private var audioInitialised = false

    var body: some View {
        VStack {
            Button("Add") {
                sheetIsPresented = true
            }
            .sheet(isPresented: $sheetIsPresented,
                   onDismiss: {
                reloadStreams()

            }){
                AddNewStreamForm()
            }

            List(selection: $selection) {
                ForEach(streams) { stream in
                    Text(stream.name)
                    .onTapGesture {
                        selection = stream
                        onStreamSelected(stream: stream)
                    }
                }
                .onDelete { index in
                    guard let first = index.first else { return }
                    let streamsData = UserDefaults.standard.data(forKey: "streams") ?? Data()
                    var streamsArray = (try? PropertyListDecoder().decode([Stream].self, from: streamsData)) ?? []
                    streamsArray.remove(at: first)
                    UserDefaults.standard.setValue(try! PropertyListEncoder().encode(streamsArray), forKey: "streams")
                    reloadStreams()
                }
            }
            if let selection = selection, playState != .stopped {

                Text("now playing: \(selection.name)")
                Button(playState == .playing ? "Pause" : "Resume") {
                    onPlayPauseButtonPressed()
                }
            }
        }.onAppear(perform: {
            reloadStreams()
        })
    }


     private func reloadStreams() {

        let streamsData = UserDefaults.standard.data(forKey: "streams") ?? Data()
        do {
            streams = (try PropertyListDecoder().decode([Stream].self, from: streamsData))
        }
        catch (let error)
        {
            streams = []
            print(error)
        }
         let rcc = MPRemoteCommandCenter.shared()
         rcc.togglePlayPauseCommand.isEnabled = true
         rcc.nextTrackCommand.isEnabled = !streams.isEmpty
         rcc.previousTrackCommand.isEnabled = !streams.isEmpty
    }

    private func onPlayPauseButtonPressed() {

        switch playState {
        case .paused:
            player.play()
            playState = .playing
            try? AVAudioSession.sharedInstance().setActive(true)
        case .playing:
            player.pause()
            try? AVAudioSession.sharedInstance().setActive(false)
            playState = .paused
        default: ()
        }
    }

    private func onStreamSelected(stream: Stream) {

        if !audioInitialised {
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playback, mode: .default, options: [.duckOthers, .allowBluetooth, .allowAirPlay, .allowBluetoothA2DP])
                try session.setActive(true)
            } catch {
                // Handle error.
            }
            let rcc = MPRemoteCommandCenter.shared()
            rcc.nextTrackCommand.addTarget { event in
                
                if let index = selection.flatMap(streams.firstIndex(of:)) {
                    selection = streams[(index + 1) % streams.count]
                    onStreamSelected(stream: selection!)
                }
                return .success
            }

            rcc.previousTrackCommand.addTarget { event in
                
                if var index = selection.flatMap(streams.firstIndex(of:)) {

                    index = index == 0 ? streams.count - 1 : index - 1
                    let stream =  streams[index]
                    selection = stream
                    onStreamSelected(stream: stream)
                }
                return .success
            }

            rcc.togglePlayPauseCommand.addTarget { event in
                
                onPlayPauseButtonPressed()
                return .success
            }
            audioInitialised = true
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: stream.name]
        
       
        player.replaceCurrentItem(with: AVPlayerItem(url: stream.url))
        player.play()
        playState = .playing
    }
    
}

struct ContentView_Previews: PreviewProvider {

    init() {
        let streamsArray: [Stream] = []
        UserDefaults.standard.setValue(try! PropertyListEncoder().encode(streamsArray), forKey: "streams")
    }

    static var previews: some View {
        Group {

            ContentView()
//            ContentView(streams: [
//                ]
//            )
        }
    }
}
