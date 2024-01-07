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
    @State private var alertIsBeingPresented = false
    @State private var selection: Stream?
    @State private var audioInitialised = false
    @State private var state: StreamPlayerEngine.PlayState = .stopped
    @State private var newStreamName: String = ""
    @State private var newStreamURL: String = ""
    @State private var addStreamOKButtonEnabled = false
    
    var body: some View {
        NavigationStack {
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
                .onMove(perform: move)
            }
            .toolbar {
                HStack {
                    Button("Add", action: {
                        if let clipboardString = UIPasteboard.general.string,
                           let clipboardURL = URL(string: clipboardString),
                           ["http", "https"].contains(clipboardURL.scheme) &&
                           clipboardURL.host?.isEmpty == false {
                            
                            newStreamURL = clipboardString
                        }
                        alertIsBeingPresented = true
                    })
                        .alert("New Stream", isPresented: $alertIsBeingPresented) {
                            TextField("Name", text: $newStreamName).onChange(of: newStreamName, perform: validateNewStreamInput)
                            TextField("URL", text: $newStreamURL).onChange(of: newStreamURL, perform: validateNewStreamInput)
                            Button (action: {
                                addNewStream()
                            }, label: {
                                Text("Add")
                            })
                            Button(action : {}, 
                                   label: {
                                Text("Cancel")
                            })
                        }
                }
                    Spacer()
                    EditButton()
                }
            
            if let selection = selection, streamPlayerEngine.state != .stopped {
                
                Text("now playing: \(selection.name)").padding([.top], 10)
                Button(state == .playing ? "Pause" : "Resume") {
                    streamPlayerEngine.playPauseToggle()
                }
                .frame(minHeight: 44).padding([.bottom], 20)
            }
        }.onAppear(perform: {
            streamPlayerEngine.onPlayStateUpdate = {
                state = streamPlayerEngine.state
            }
            reloadStreams()
        })
    }
}

private extension ContentView {

    func alertOKAction() {
        addNewStream()
        newStreamName = ""
        newStreamURL = ""
    }
    
    
    func validateNewStreamInput(_ value: String) {
     
        let urlValid: Bool
        if let url = URLComponents(string: newStreamURL),
           ["http", "https"].contains(url.scheme),
           url.host?.isEmpty == false {
            urlValid = true
        }
        else {
            urlValid = false
        }
        addStreamOKButtonEnabled = !newStreamName.isEmpty && urlValid
    }
    
    func addNewStream() {
        
        if let url = URL(string: newStreamURL), !newStreamName.isEmpty {
            
            StreamsRepository.shared.appendStream(Stream(url: url, name: newStreamName))
            reloadStreams()
            newStreamURL = ""
            newStreamName = ""
        }
    }
    
    func reloadStreams() {

         streams = StreamsRepository.shared.streams
    }

    func onStreamSelected(stream: Stream) {

        streamPlayerEngine.play(stream: stream)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        
        StreamsRepository.shared.move(from: source, to: destination)
        reloadStreams()
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
