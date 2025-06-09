//
//  ShareContentView.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import SwiftUI

struct ShareContentView: View {
    let sharedURL: URL
    var onSave: (String, String) -> URL?
    var onOpen: (URL) -> Void

    @State private var chosenFolder = ""
    @State private var fileName = ""
    @State private var showingNewFolder = false
    @State private var refreshID = UUID()
    @State private var savedURL: URL?
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            FolderPickerView(subpath: "") { folder in
                chosenFolder = folder
                fileName = sharedURL.lastPathComponent
            }
            .id(refreshID)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Maak Submap") {
                        showingNewFolder = true
                    }
                    .disabled(chosenFolder.isEmpty)
                }
            }

            // Once a folder is chosen, show name & Save
            if !chosenFolder.isEmpty {
                Form {
                    Section(header: Text("Gids: \(chosenFolder)")) { }
                    Section(header: Text("Naam")) {
                        TextField(sharedURL.lastPathComponent, text: $fileName)
                    }
                    Section {
                        Button("Stoor Lêer") {
                            if let dest = onSave(
                                chosenFolder,
                                fileName.isEmpty ? sharedURL.lastPathComponent : fileName
                            ) {
                                savedURL = dest
                                showSuccess = true
                            }
                        }
                    }
                }
                .navigationTitle("Baskanselleer")
            }
        }
        .sheet(isPresented: $showingNewFolder) {
            NewSubfolderSheet(title: "Nuwe Submap", placeholder: "Naam") { name in
                try? SharedFileManager.createSubfolder(named: name, in: chosenFolder)
                refreshID = UUID()
            }
        }
        .alert("Successfully saved", isPresented: $showSuccess) {
            Button("Open") {
                if let dest = savedURL {
                    onOpen(dest)
                }
            }
            Button("Done", role: .cancel) {}
        }
    }
}

private struct NewSubfolderSheet: View {
    let title: String
    let placeholder: String
    var onCreate: (String) -> Void

    @Environment(\.presentationMode) private var presentationMode
    @State private var name = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(title)) {
                    TextField(placeholder, text: $name)
                }
            }
            .navigationTitle(title)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Create") {
                    onCreate(name.trimmingCharacters(in: .whitespaces))
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            )
        }
    }
}
