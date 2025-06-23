import SwiftUI

struct AanbevelingsView: View {
    @StateObject private var store = AanbevelingStore()
    @State private var showingAdd = false
    @State private var renameTarget: Client?
    @Environment(\.editMode) private var editMode

    var body: some View {
        List {
            ForEach(store.clients) { client in
                NavigationLink {
                    ClientAanbevelingView(client: client, store: store)
                } label: {
                    Text(client.name)
                }
                .swipeActions {
                    Button("Delete", role: .destructive) {
                        store.delete(client: client)
                    }
                }
                .contextMenu {
                    Button("Copy") { store.duplicate(client: client) }
                    Button("Rename") { renameTarget = client }
                    Button("Delete", role: .destructive) {
                        store.delete(client: client)
                    }
                }
            }
            .onMove { indices, newOffset in
                store.moveClients(at: indices, to: newOffset)
            }
        }
        .navigationTitle("Aanbevelings")
        .navigationBarItems(
            trailing: HStack {
                EditButton()
                Button("Add Client") { showingAdd = true }
            }
        )
        .sheet(isPresented: $showingAdd) {
            AddClientSheet { name in
                store.addClient(named: name)
            }
        }
        .sheet(item: $renameTarget) { client in
            RenameClientSheet(client: client) { newName in
                store.rename(client: client, to: newName)
            }
        }
    }
}

struct AddClientSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    var onAdd: (String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Client Name", text: $name)
            }
            .navigationTitle("Add Client")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Add") {
                    onAdd(name)
                    dismiss()
                }
                .disabled(name.isEmpty)
            )
        }
    }
}

struct RenameClientSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    let client: Client
    var onRename: (String) -> Void

    init(client: Client, onRename: @escaping (String) -> Void) {
        self.client = client
        self.onRename = onRename
        _name = State(initialValue: client.name)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Client Name", text: $name)
            }
            .navigationTitle("Rename Client")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    onRename(name.trimmingCharacters(in: .whitespaces))
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            )
        }
    }
}

#Preview {
    NavigationStack {
        AanbevelingsView()
    }
}
