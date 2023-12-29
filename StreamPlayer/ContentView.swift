//
//  ContentView.swift
//  StreamPlayer
//
//  Created by Knut Lorenzen on 23/10/2022.
//

import SwiftUI
import AVFoundation
import MediaPlayer


struct ContentView: View {

    @State private var streams: [Stream] = []
    private var streamPlayerEngine = StreamPlayerEngine()
    @State private var sheetIsPresented = false
    @State private var selection: Stream?
    @State private var audioInitialised = false
    @State private var state: StreamPlayerEngine.PlayState = .stopped

    var body: some View {
        VStack {
            Spacer().frame(height: 20)
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
                    HStack {
                        let margin: CGFloat = 15
                        Spacer().frame(minWidth: margin, maxWidth: margin)
                        Text(stream.name)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selection = stream
                        onStreamSelected(stream: stream)
                    }
                }
                .onDelete { index in
                    guard let first = index.first else { return }
                    StreamsRepository.shared.deleteStream(at: first)
                    reloadStreams()
                }
            }
            if let selection = selection, streamPlayerEngine.state != .stopped {

                Text("now playing: \(selection.name)")
                Button(state == .playing ? "Pause" : "Resume") {
                    streamPlayerEngine.playPauseToggle()
                }
            }
        }.onAppear(perform: {
            streamPlayerEngine.onPlayStateUpdate = {
                state = streamPlayerEngine.state
            }
            reloadStreams()
        })
    }


     private func reloadStreams() {

         streams = StreamsRepository.shared.streams
    }

    private func onStreamSelected(stream: Stream) {

        streamPlayerEngine.play(stream: stream)
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
