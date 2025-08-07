//
//  FolderView.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import SwiftUI
import UniformTypeIdentifiers

struct FolderView: View {
    @ObservedObject var service: FileManagerService
    let title: String
    var openFileURL: URL? = nil

    @State private var showingNewFolder = false
    @State private var showingImporter = false
    @State private var shareURL: URL?
    @State private var renameTarget: DirectoryItem?
    @State private var moveTarget: DirectoryItem?
    @State private var previewURL: URL?
    @State private var sortMode: SortMode = .name
    @State private var searchText = ""

    enum SortMode { case name, date }

    var filteredItems: [DirectoryItem] {
        let base = searchText.isEmpty
            ? service.items
            : service.items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        switch sortMode {
        case .name:
            return base.sorted {
                if $0.isDirectory && !$1.isDirectory { return true }
                if !$0.isDirectory && $1.isDirectory { return false }
                return $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
        case .date:
            return base.sorted {
                let d0 = (try? $0.id.resourceValues(forKeys: [.contentModificationDateKey])
                                .contentModificationDate) ?? Date.distantPast
                let d1 = (try? $1.id.resourceValues(forKeys: [.contentModificationDateKey])
                                .contentModificationDate) ?? Date.distantPast
                return d0 > d1
            }
        }
    }

    var body: some View {
        Group {
            if service.isLoading {
                LoadingView(message: "Loading files...")
            } else if let error = service.error {
                ErrorView(error: error) {
                    service.loadItemsAsync()
                }
            } else if filteredItems.isEmpty {
                if searchText.isEmpty {
                    EmptyStateView(
                        title: "No Documents",
                        message: "Import product labels, safety data, or create spray programs for your clients. Tap the menu button to get started.",
                        systemImage: "doc.badge.plus",
                        actionButton: (title: "Import File", action: {
                            showingImporter = true
                        })
                    )
                } else {
                    EmptyStateView(
                        title: "No Results",
                        message: "No files match your search. Try different keywords or clear your search.",
                        systemImage: "magnifyingglass",
                        actionButton: (title: "Clear Search", action: {
                            searchText = ""
                        })
                    )
                }
            } else {
                List {
                    ForEach(filteredItems) { item in
                        row(for: item)
                    }
                    .onDelete { idxs in
                        idxs.forEach { service.delete(item: filteredItems[$0]) }
                    }
                }
            }
        }
        .searchable(text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle(title)
        .navigationBarItems(
            trailing: Menu {
                Button("New Folder") { showingNewFolder = true }
                Button("Import File") { showingImporter = true }
                Divider()
                Picker("Sort by", selection: $sortMode) {
                    Label("Name", systemImage: "textformat").tag(SortMode.name)
                    Label("Date", systemImage: "calendar").tag(SortMode.date)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 22))
            }
        )
        .sheet(isPresented: $showingNewFolder) {
            NewFolderSheet(title: "New Folder", placeholder: "Name") { name in
                service.createFolder(named: name)
                Haptics.success()
            }
        }
        .fileImporter(isPresented: $showingImporter,
                      allowedContentTypes: [.pdf, .spreadsheet],
                      allowsMultipleSelection: true) { result in
            if case .success(let urls) = result {
                urls.forEach { service.importFile(from: $0) }
                Haptics.success()
            }
        }
        .sheet(item: $shareURL) { url in
            ShareSheet(activityItems: [url])
        }
        .sheet(item: $renameTarget) { item in
            RenameSheet(item: item) { newName in
                service.rename(item: item, to: newName)
            }
        }
        .sheet(item: $moveTarget) { item in
            FolderPickerView(subpath: "") { path in
                service.move(item: item, to: path)
                moveTarget = nil
            }
        }
        .sheet(item: $previewURL) { url in
            FilePreviewView(url: url)
        }
        .onAppear {
            service.loadItemsAsync()
            if let open = openFileURL {
                previewURL = open
            }
        }
    }

    @ViewBuilder
    private func row(for item: DirectoryItem) -> some View {
        if item.isDirectory {
            NavigationLink(
                destination: FolderView(service: service.navigate(to: item),
                                        title: item.name)
            ) {
                Label(item.name, systemImage: "folder.fill")
            }
            .simultaneousGesture(TapGesture().onEnded { Haptics.selection() })
            .contextMenu {
                Button("Rename") { renameTarget = item }
                Button("Move") { moveTarget = item }
                Button("Delete", role: .destructive) {
                    service.delete(item: item)
                }
            }
        } else {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        fileIcon(for: item)
                        Text(item.name)
                            .lineLimit(1)
                        Spacer()
                        Button { shareURL = item.id } label: {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text(item.formattedFileSize)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(item.formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                Haptics.selection()
                previewURL = item.id
            }
            .contextMenu {
                Button("Open") { previewURL = item.id }
                Button("Share") { shareURL = item.id }
                if item.id.pathExtension.lowercased().contains("xls") {
                    Button("Send as PDF") {
                        if let url = service.exportAsPDF(item: item) {
                            shareURL = url
                        }
                    }
                }
                Button("Duplicate") { service.duplicate(item: item) }
                Button("Rename") { renameTarget = item }
                Button("Move") { moveTarget = item }
                Button("Delete", role: .destructive) {
                    service.delete(item: item)
                }
            }
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    service.delete(item: item)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                Button {
                    renameTarget = item
                } label: {
                    Label("Rename", systemImage: "pencil")
                }
                .tint(.orange)
            }
        }
    }
    
    @ViewBuilder
    private func fileIcon(for item: DirectoryItem) -> some View {
        if item.isPDF {
            Image(systemName: "doc.fill")
                .foregroundColor(.red)
        } else if item.isExcel {
            Image(systemName: "tablecells")
                .foregroundColor(.green)
        } else if item.isWord {
            Image(systemName: "doc.text.fill")
                .foregroundColor(.blue)
        } else if item.isImage {
            Image(systemName: "photo.fill")
                .foregroundColor(.purple)
        } else if item.isText {
            Image(systemName: "doc.text")
                .foregroundColor(.orange)
        } else {
            Image(systemName: "doc.fill")
                .foregroundColor(.gray)
        }
    }
}
