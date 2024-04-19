//
//  ContentView.swift
//  StreamPlayer
//
//  Created by Knut on 08/04/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State var editMode: EditMode = .inactive
    @State private var newStreamAlertIsBeingPresented = false
    @State private var streamEditAlertIsBeingPresented = false
    @Query private var streamList: [StreamList]
    @State private var editingStreamIndex: Int? = nil


    @StateObject private var streamPlayerEngine = StreamPlayerEngine()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(streamList[0].streams) { stream in
                    HStack {
                        let margin: CGFloat = 15
                        Spacer().frame(minWidth: margin, maxWidth: margin)
                        Text(stream.name)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        
                        if editMode.isEditing == true {
                            editingStreamIndex = streamList[0].streams.firstIndex(where: { $0 == stream })
                            streamEditAlertIsBeingPresented = true
                        }
                        else {
                            streamPlayerEngine.play(stream: stream)
                        }
                    }
                    .alert("Edit Stream", isPresented: $streamEditAlertIsBeingPresented) {
                        
                        if streamEditAlertIsBeingPresented,
                           let editingStreamIndex = editingStreamIndex,
                           editingStreamIndex < streamList[0].streams.count {
                            
                            StreamEditView(okAction: { updatedStream in
                                
                                streamList[0].streams[editingStreamIndex] = updatedStream
                                self.editingStreamIndex = nil
                            },
                                           
                                           name: streamList[0].streams[editingStreamIndex].name,
                                           url: streamList[0].streams[editingStreamIndex].url.absoluteString,
                                           actionLabel: "Save"
                            )
                        }
                    }
                }
                .onDelete(perform: deleteItems(offsets:))
                .onMove(perform: rearrangeStream(indexSet:index:))
            }
            .toolbar {
#if os(macOS)
                GroupBox() {
                    HStack {
                        Button(action: {
                            // newStreamAlertIsBeingPresented = true
                        }, label: {
                            Image(systemName: "plus")
                        })
                        Button(action: {
                            // newStreamAlertIsBeingPresented = true
                        }, label: {
                            Image(systemName: "pencil")
                        })
                    }
                }
#elseif os(iOS)
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button(action: {
                        newStreamAlertIsBeingPresented = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                    .alert("New Stream", isPresented: $newStreamAlertIsBeingPresented) {
                        if newStreamAlertIsBeingPresented {
                            StreamEditView(okAction: addStream(_:),
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
#endif
            }
            .environment(\.editMode, $editMode)

            if let currentlyPlaying = streamPlayerEngine.currentStream, streamPlayerEngine.state != .stopped {
                
                Text("now playing: \(currentlyPlaying.name)").padding([.top], 10)
                HStack {
                    if streamList[0].streams.count > 1 {
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
                        Image(systemName: streamPlayerEngine.state == .playing ? "pause" : "play")
                    })
                    .frame(minHeight: 44)
                    if streamList[0].streams.count > 1 {
                        Button(action: {
                            streamPlayerEngine.skipForward()
                        }, label: {
                            Image(systemName: "forward")
                        })
                        .frame(minHeight: 44)
                    }
                }.padding([.bottom], 20)
            }
        }
        .onAppear() {
            streamPlayerEngine.modelContext = modelContext
        }
    }

    private func addStream(_ stream: Stream) {
        
        withAnimation {
            streamList[0].streams.append(stream)
        }
    }
    
    private func rearrangeStream(indexSet: IndexSet, index: Int) {
        
        streamList[0].streams.move(fromOffsets: indexSet, toOffset: index)
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            streamList[0].streams.remove(atOffsets: offsets)
        }
    }
}


private extension ContentView {
    
    func getURLFromClipboard() -> String {
        #if os(iOS)
        if UIPasteboard.general.hasStrings,
           let clipboardString = UIPasteboard.general.string,
           clipboardString.isValidWebURL {
            
            return clipboardString
        }
        else {
            return ""
        }
        #else
            return ""
        #endif
    }
}


#Preview {
    ContentView()
        .modelContainer(for: Stream.self, inMemory: true)
}
