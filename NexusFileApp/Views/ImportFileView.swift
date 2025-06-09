import SwiftUI

/// View presented when the app is opened with a file from another app.
/// Allows the user to select a destination folder and file name.
struct ImportFileView: View {
    let fileURL: URL
    var onComplete: () -> Void

    @State private var chosenFolder = ""
    @State private var fileName = ""
    @State private var showingNewFolder = false
    @State private var refreshID = UUID()

    var body: some View {
        NavigationStack {
            FolderPickerView(subpath: "") { folder in
                chosenFolder = folder
                fileName = fileURL.lastPathComponent
            }
            .id(refreshID)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New Folder") {
                        showingNewFolder = true
                    }
                    .disabled(chosenFolder.isEmpty)
                }
            }

            if !chosenFolder.isEmpty {
                Form {
                    Section(header: Text("Folder: \(chosenFolder)")) { }
                    Section(header: Text("Name")) {
                        TextField(fileURL.lastPathComponent, text: $fileName)
                    }
                    Section {
                        Button("Save File") {
                            try? SharedFileManager.shared.save(
                                file: fileURL,
                                to: chosenFolder,
                                named: fileName.isEmpty ? fileURL.lastPathComponent : fileName
                            )
                            onComplete()
                        }
                    }
                }
                .navigationTitle("Import File")
            }
        }
        .sheet(isPresented: $showingNewFolder) {
            NewFolderSheet(title: "New Subfolder", placeholder: "Name") { name in
                try? SharedFileManager.shared.createSubfolder(named: name, in: chosenFolder)
                refreshID = UUID()
            }
        }
    }
}
