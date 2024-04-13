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
    @State private var newStreamAlertIsBeingPresented = false
    @Query private var streams: [Stream]

    var body: some View {
        NavigationStack {
            List {
                ForEach(streams) { stream in
                    HStack {
                        let margin: CGFloat = 15
                        Spacer().frame(minWidth: margin, maxWidth: margin)
                        Text(stream.name)
                        Spacer()
                    }
                }
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
        }
//        NavigationSplitView {
//            List {
//                ForEach(streams) { stream in
//                    NavigationLink {
//                        Text("stream at ")
//                    } label: {
//                        Text("nil")
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//#if os(macOS)
//            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
//#endif
//            .toolbar {
//#if os(iOS)
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//#endif
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//        } detail: {
//            Text("Select an item")
//        }
    }

    private func addStream(_ stream: Stream) {
        
        withAnimation {
            modelContext.insert(stream)
        }
    }
    
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(streams[index])
            }
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
