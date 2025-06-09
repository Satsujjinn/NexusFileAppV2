import SwiftUI

/// Displays a navigable list of folders so the user can choose where to
/// store an imported file.
struct FolderPickerView: View {
    /// The path relative to the shared Documents directory.
    let subpath: String
    /// Called when the user taps "Save in …" for the current folder.
    var onSelect: (String) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("Folders") {
                    ForEach(SharedFileManager.shared.listFolders(at: subpath), id: \.
self) { name in
                        let nextPath = subpath.isEmpty ? name : "\(subpath)/\(name)"
                        NavigationLink {
                            FolderPickerView(subpath: nextPath, onSelect: onSelect)
                        } label: {
                            Text(name)
                        }
                    }
                }

                if !subpath.isEmpty {
                    Section {
                        Button("Save in \"\(subpath)\"") {
                            onSelect(subpath)
                        }
                    }
                }
            }
            .navigationTitle(subpath.isEmpty ? "Choose Folder" : subpath)
        }
    }
}
