//
//  HomeView.swift
//  NexusFileApp
//
//  Created by Theunis Jordaan on 2025/05/19.
//

import SwiftUI

struct HomeView: View {
    @Binding var openFileURL: URL?
    @StateObject private var fm = FileManagerService()
    @State private var showingNew = false
    @State private var renameTarget: DirectoryItem?
    @State private var pendingFile: URL?
    @State private var navigateService: FileManagerService?
    @State private var showSavedAlert = false

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    NavigationLink(destination: CalibrationsView()) {
                        CategoryCard(name: "Calibrations")
                    }
                    .simultaneousGesture(TapGesture().onEnded { Haptics.selection() })

                    ForEach(fm.items.filter(\.isDirectory)) { item in
                        NavigationLink(
                            destination: FolderView(
                                service: fm.navigate(to: item),
                                title: item.name
                            )
                        ) {
                            CategoryCard(name: item.name)
                        }
                        .simultaneousGesture(TapGesture().onEnded { Haptics.selection() })
                        .contextMenu {
                            Button("Rename") { renameTarget = item }
                            Button("Delete", role: .destructive) {
                                fm.delete(item: item)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.nexusBackground.ignoresSafeArea())
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button { fm.syncFromICloud() } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    Button { fm.backupToICloud() } label: {
                        Image(systemName: "icloud.and.arrow.up")
                    }
                    Button { showingNew = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                    }
                }
            }
            .sheet(isPresented: $showingNew) {
                NewFolderSheet(
                    title: "New Category",
                    placeholder: "Name"
                ) { name in
                    fm.createFolder(named: name)
                    Haptics.success()
                }
            }
            .sheet(item: $renameTarget) { item in
                RenameSheet(item: item) { newName in
                    fm.rename(item: item, to: newName)
                }
            }
            .onAppear { fm.loadItems() }
            .alert("Successfully saved", isPresented: $showSavedAlert) {
                Button("Open") {
                    if let file = pendingFile {
                        let folder = file.deletingLastPathComponent()
                        navigateService = FileManagerService(startingAt: folder,
                                                             documentsURL: SharedFileManager.shared.documentsURL)
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .background(
                NavigationLink(
                    destination: destinationView(),
                    isActive: Binding(
                        get: { navigateService != nil },
                        set: { if !$0 { navigateService = nil } }
                    )
                ) { EmptyView() }
                .hidden()
            )
            .onChange(of: openFileURL) { url in
                if let url {
                    pendingFile = url
                    showSavedAlert = true
                    openFileURL = nil
                }
            }
        }
    }

    @ViewBuilder
    private func destinationView() -> some View {
        if let service = navigateService {
            FolderView(
                service: service,
                title: service.currentURL.lastPathComponent,
                openFileURL: pendingFile
            )
        } else {
            EmptyView()
        }
    }
}
