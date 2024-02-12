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
    
    @State var editMode: EditMode = .inactive
    @State private var streams: [Stream] = []
    private var streamPlayerEngine = StreamPlayerEngine()
    @State private var newStreamAlertIsBeingPresented = false
    @State private var streamEditAlertIsBeingPresented = false
    @State private var selection: Stream?
    @State private var editingStreamIndex: Int? = nil
    @State private var audioInitialised = false
    @State private var state: StreamPlayerEngine.PlayState = .stopped
    @State private var addStreamOKButtonEnabled = false
    @State var name: String = ""
    
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
                        
                        if editMode.isEditing == true {
                            editingStreamIndex = streams.firstIndex(where: { $0 == stream })
                            streamEditAlertIsBeingPresented = true
                        }
                        else {
                            selection = stream
                            onStreamSelected(stream: stream)
                        }
                    }
                    .alert("Edit Stream", isPresented: $streamEditAlertIsBeingPresented) {
                                  
                        if streamEditAlertIsBeingPresented,
                           let editingStreamIndex = editingStreamIndex,
                           editingStreamIndex < streams.count {
                            
                            StreamEditView(okAction: { updatedStream in
                                
                                StreamsRepository.shared.updateStream(at: editingStreamIndex, stream: updatedStream)
                                self.editingStreamIndex = nil
                                reloadStreams()
                            },
        
                                           name: streams[editingStreamIndex].name,
                                           url: streams[editingStreamIndex].url.absoluteString,
                                           actionLabel: "Save"
                            )
                        }
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
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button(action: {
                        newStreamAlertIsBeingPresented = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                    
                    .alert("New Stream", isPresented: $newStreamAlertIsBeingPresented) {
                        if newStreamAlertIsBeingPresented {
                            StreamEditView(okAction: { stream in
                                StreamsRepository.shared.appendStream(stream)
                                reloadStreams()
                            },
                                           name: "",
                                           url: getURLFromClipboard(),
                                           actionLabel: "Add"
                            )
                        }
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            .environment(\.editMode, $editMode)
            
            if let selection = selection, streamPlayerEngine.state != .stopped {
                
                Text("now playing: \(selection.name)").padding([.top], 10)
                HStack {
                    if streams.count > 1 {
                        Button(action: {
                            streamPlayerEngine.skipBackward()
                        }, label: {
                            Image(systemName: "backward")
                        })
                        .frame(minHeight: 44)
                    }
                    
                    Button(action:  {
                        streamPlayerEngine.playPauseToggle()
                    }, label: {
                        Image(systemName: state == .playing ? "pause" : "play")
                    })
                    .frame(minHeight: 44)
                    if streams.count > 1 {
                        Button(action: {
                            streamPlayerEngine.skipForward()
                        }, label: {
                            Image(systemName: "forward")
                        })
                        .frame(minHeight: 44)
                    }
                }.padding([.bottom], 20)
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

    func getURLFromClipboard() -> String {
        
        if UIPasteboard.general.hasStrings, 
            let clipboardString = UIPasteboard.general.string,
           clipboardString.isValidWebURL {
            
            return clipboardString
        }
        else {
            return ""
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

struct StreamEditView : View {
    
    internal var okAction: (Stream) -> Void = { _ in }
    @State internal var name: String = ""
    @State internal var url: String = ""
    @State internal var actionLabel: String = ""
    
    var body : some View {
        
        TextField("Name", text: $name)
        TextField("URL", text: $url)
        
        Button (action: {
            if let url = URL(string: url), !name.isEmpty {
                okAction(Stream(url: url, name: name))
            }
        }, label: {
            Text(actionLabel)
        })
        Button(action : {},
               label: {
            Text("Cancel")
        })
    }
}



extension String {
    
    var isValidWebURL: Bool {
        
        guard let asURL = URL(string: self),
              ["http", "https"].contains(asURL.scheme) &&
                asURL.host?.isEmpty == false else { 
            return false
        }
        return true
    }
}
