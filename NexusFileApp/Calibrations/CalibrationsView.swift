import SwiftUI

struct CalibrationsView: View {
    @StateObject private var store = CalibrationStore()
    @State private var showingAdd = false
    @State private var renameTarget: Farmer?
    @State private var searchText = ""
    @Environment(\.editMode) private var editMode

    var filteredFarmers: [Farmer] {
        if searchText.isEmpty {
            return store.farmers
        } else {
            return store.farmers.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        Group {
            if store.farmers.isEmpty {
                EmptyStateView(
                    title: "No Spray Programs",
                    message: "Create your first spray program calibration for a client. This will help you organize tractor settings and application rates.",
                    systemImage: "tractor.fill",
                    actionButton: (title: "Create Program", action: {
                        showingAdd = true
                    })
                )
            } else {
                List {
                    ForEach(filteredFarmers) { farmer in
                        NavigationLink {
                            FarmerCalibrationView(farmer: farmer, store: store)
                        } label: {
                            ClientRow(farmer: farmer)
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Delete", role: .destructive) {
                                store.delete(farmer: farmer)
                            }
                            Button("Duplicate") {
                                store.duplicate(farmer: farmer)
                            }
                            .tint(.orange)
                        }
                        .contextMenu {
                            Button("Open Spray Program") {
                                // Navigation will handle this
                            }
                            Button("Duplicate Program") {
                                store.duplicate(farmer: farmer)
                            }
                            Button("Rename Client") {
                                renameTarget = farmer
                            }
                            Button("Delete Program", role: .destructive) {
                                store.delete(farmer: farmer)
                            }
                        }
                    }
                    .onMove { indices, newOffset in
                        store.moveFarmers(at: indices, to: newOffset)
                    }
                }
                .searchable(text: $searchText, prompt: "Search clients...")
            }
        }
        .navigationTitle("Spray Programs")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(
            trailing: HStack {
                EditButton()
                Button {
                    showingAdd = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                }
            }
        )
        .sheet(isPresented: $showingAdd) {
            AddClientSheet { name in
                store.addFarmer(named: name)
                Haptics.success()
            }
        }
        .sheet(item: $renameTarget) { farmer in
            RenameClientSheet(farmer: farmer) { newName in
                store.rename(farmer: farmer, to: newName)
                Haptics.success()
            }
        }
    }
}

struct ClientRow: View {
    let farmer: Farmer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "tractor.fill")
                    .foregroundColor(.nexusGreen)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(farmer.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(farmer.recommendations.count) calibration entries")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !farmer.recommendations.isEmpty {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
            }
            
            if !farmer.recommendations.isEmpty {
                HStack {
                    Text("Last updated: \(formattedDate)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(farmer.recommendations.filter { !$0.isHeader }.count) tractors")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var formattedDate: String {
        // For now, show a placeholder. In a real app, you'd track modification dates
        "Today"
    }
}

struct AddClientSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    var onAdd: (String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Client/Farm Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } header: {
                    Text("Client Information")
                } footer: {
                    Text("Enter the name of the client or farm for this spray program")
                }
            }
            .navigationTitle("New Spray Program")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Create") {
                    onAdd(name.trimmingCharacters(in: .whitespaces))
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            )
        }
    }
}

struct RenameClientSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    let farmer: Farmer
    var onRename: (String) -> Void

    init(farmer: Farmer, onRename: @escaping (String) -> Void) {
        self.farmer = farmer
        self.onRename = onRename
        _name = State(initialValue: farmer.name)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Client/Farm Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } header: {
                    Text("Client Information")
                } footer: {
                    Text("Update the name of the client or farm")
                }
            }
            .navigationTitle("Rename Client")
            .navigationBarTitleDisplayMode(.inline)
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
        CalibrationsView()
    }
}
