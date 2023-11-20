//
//  ContentView.swift
//  StreamPlayer
//
//  Created by Knut Lorenzen on 23/10/2022.
//

import SwiftUI
import AVFoundation

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


    var body: some View {
        VStack {
            Button("Add") {
                sheetIsPresented = true
            }
            .sheet(isPresented: $sheetIsPresented){
                AddNewStreamForm()
            }

            List(selection: $selection) {
                ForEach(streams) { stream in
                    Text(stream.name).onTapGesture {
                        selection = stream
                        onStreamSelected(stream: stream)
                    }
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
        ()
    }

    private func onPlayPauseButtonPressed() {

        switch playState {
        case .paused:
            player.play()
            playState = .playing
        case .playing:
            player.pause()
            playState = .paused
        default: ()
        }
    }

    private func onStreamSelected(stream: Stream) {

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
