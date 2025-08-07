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
    @State private var showingSettings = false
    @State private var renameTarget: DirectoryItem?
    @State private var pendingFile: URL?
    @State private var navigateService: FileManagerService?
    @State private var showSavedAlert = false

    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var columns: [GridItem] {
        let count = verticalSizeClass == .compact ? 3 : 2
        return Array(repeating: GridItem(.flexible()), count: count)
    }

    var body: some View {
        NavigationStack {
            Group {
                if fm.isLoading {
                    LoadingView(message: "Loading categories...")
                } else if let error = fm.error {
                    ErrorView(error: error) {
                        fm.loadItemsAsync()
                    }
                } else if fm.items.filter(\.isDirectory).isEmpty {
                    EmptyStateView(
                        title: "No Categories",
                        message: "Create your first category to get started organizing your agricultural documents and spray programs.",
                        systemImage: "folder.badge.plus",
                        actionButton: (title: "Create Category", action: {
                            showingNew = true
                        })
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                                                NavigationLink(destination: CalibrationsView()) {
                        CategoryCard(name: "Spray Programs", tint: .nexusGreen, icon: "tractor.fill")
                    }
                            .simultaneousGesture(TapGesture().onEnded { Haptics.selection() })
                            ForEach(fm.items.filter(\.isDirectory)) { item in
                                NavigationLink(
                                    destination: FolderView(
                                        service: fm.navigate(to: item),
                                        title: item.name
                                    )
                                ) {
                                    CategoryCard(name: item.name, icon: getIconForCategory(item.name))
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
                }
            }
            .background(Color.white.ignoresSafeArea())
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20))
                }
                .accessibilityLabel("Settings")
                .accessibilityHint("Open app settings and preferences"),
                trailing: Button { showingNew = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                }
                .accessibilityLabel("New Category")
                .accessibilityHint("Create a new category folder")
            )
            .sheet(isPresented: $showingNew) {
                NewFolderSheet(
                    title: "New Category",
                    placeholder: "Name"
                ) { name in
                    fm.createFolder(named: name)
                    Haptics.success()
                }
            }
            .sheet(isPresented: $showingSettings) {
                GeneralSettingsView()
            }
            .sheet(item: $renameTarget) { item in
                RenameSheet(item: item) { newName in
                    fm.rename(item: item, to: newName)
                }
            }
            .onAppear { fm.loadItemsAsync() }
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
            .navigationDestination(isPresented: Binding(
                get: { navigateService != nil },
                set: { if !$0 { navigateService = nil } }
            )) {
                destinationView()
            }
            .onChange(of: openFileURL) { oldValue, newValue in
                if let url = newValue {
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
    
    private func getIconForCategory(_ categoryName: String) -> String {
        switch categoryName {
        case "Spray Programs":
            return "tractor.fill"
        case "Product Labels":
            return "tag.fill"
        case "Safety Data":
            return "shield.fill"
        case "Crop Information":
            return "leaf.fill"
        case "Client Documents":
            return "person.2.fill"
        case "Technical Data":
            return "chart.bar.fill"
        case "Saved":
            return "bookmark.fill"
        case "Crop Info":
            return "leaf.fill"
        default:
            return "folder.fill"
        }
    }
}
