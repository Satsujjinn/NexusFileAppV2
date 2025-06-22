import SwiftUI

struct CalibrationsView: View {
    @StateObject private var store = CalibrationStore()
    @State private var showingAdd = false
    @State private var renameTarget: Farmer?
    @Environment(\.editMode) private var editMode

    var body: some View {
        List {
            ForEach(store.farmers) { farmer in
                NavigationLink {
                    FarmerCalibrationView(farmer: farmer, store: store)
                } label: {
                    Text(farmer.name)
                }
                .swipeActions {
                    Button("Delete", role: .destructive) {
                        store.delete(farmer: farmer)
                    }
                }
                .contextMenu {
                    Button("Copy") { store.duplicate(farmer: farmer) }
                    Button("Rename") { renameTarget = farmer }
                    Button("Delete", role: .destructive) {
                        store.delete(farmer: farmer)
                    }
                }
            }
            .onMove { indices, newOffset in
                store.moveFarmers(at: indices, to: newOffset)
            }
        }
        .navigationTitle("Calibration Sheets")
        .navigationBarItems(
            trailing: HStack {
                EditButton()
                Button("Add Farmer") { showingAdd = true }
            }
        )
        .sheet(isPresented: $showingAdd) {
            AddFarmerSheet { name in
                store.addFarmer(named: name)
            }
        }
        .sheet(item: $renameTarget) { farmer in
            RenameFarmerSheet(farmer: farmer) { newName in
                store.rename(farmer: farmer, to: newName)
            }
        }
    }
}

struct AddFarmerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    var onAdd: (String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Farmer Name", text: $name)
            }
            .navigationTitle("Add Farmer")
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

struct RenameFarmerSheet: View {
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
                TextField("Farmer Name", text: $name)
            }
            .navigationTitle("Rename Farmer")
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
