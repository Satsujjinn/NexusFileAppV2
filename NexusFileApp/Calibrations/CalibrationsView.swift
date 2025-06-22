import SwiftUI

struct CalibrationsView: View {
    @StateObject private var store = CalibrationStore()
    @State private var showingAdd = false
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

#Preview {
    NavigationStack {
        CalibrationsView()
    }
}
