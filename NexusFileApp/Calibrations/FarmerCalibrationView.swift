import SwiftUI

struct FarmerCalibrationView: View {
    let farmer: Farmer
    @ObservedObject var store: CalibrationStore
    /// Latest copy of the farmer from the store if available
    private var currentFarmer: Farmer {
        store.farmers.first(where: { $0.id == farmer.id }) ?? farmer
    }
    @State private var showAddHeader = false
    @State private var selection = Set<UUID>()
    @State private var showExportOptions = false
    @Environment(\.editMode) private var editMode

    var body: some View {
        Group {
            if currentFarmer.recommendations.isEmpty {
                EmptyStateView(
                    title: "No Calibrations",
                    message: "Add tractor calibrations to create a spray program for \(currentFarmer.name)",
                    systemImage: "gearshape.2"
                )
            } else {
                List(selection: $selection) {
                    let recs = store.farmers.first(where: { $0.id == farmer.id })?.recommendations ?? []
                    let enumerated: [(Recommendation, Int?)] = {
                        var count = 0
                        return recs.map { rec in
                            if rec.isHeader {
                                count = 0
                                return (rec, nil)
                            } else {
                                count += 1
                                return (rec, count)
                            }
                        }
                    }()
                    ForEach(enumerated, id: \.0.id) { item in
                        let rec = item.0
                        if let header = rec.header {
                            HeaderRow(header: header)
                        } else if let idx = item.1 {
                            RecommendationRow(index: idx, rec: binding(for: rec))
                        }
                    }
                    .onMove { indices, newOffset in
                        store.moveRecommendations(at: indices, to: newOffset, for: currentFarmer)
                    }
                }
            }
        }
        .navigationTitle(currentFarmer.name)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(
            leading: EditButton(),
            trailing: HStack {
                if editMode?.wrappedValue == .active && !selection.isEmpty {
                    Button("Delete Selected", role: .destructive) {
                        store.deleteRecommendations(with: selection, from: currentFarmer)
                        selection.removeAll()
                        Haptics.error()
                    }
                }
                Button {
                    store.addRecommendation(to: currentFarmer)
                    Haptics.selection()
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 20))
                }
                Button {
                    showAddHeader = true
                } label: {
                    Image(systemName: "textformat.abc")
                        .font(.system(size: 20))
                }
                Menu {
                    Button("Export as Excel") {
                        exportSprayProgram(format: ExportFormat.csv)
                    }
                    Button("Export as PDF") {
                        exportSprayProgram(format: ExportFormat.pdf)
                    }
                    Button("Share Program") {
                        showExportOptions = true
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                }
            }
        )
        .safeAreaInset(edge: .bottom) {
            if !currentFarmer.recommendations.isEmpty {
                ExportButton(farmer: farmer, store: store)
                    .padding([.horizontal, .bottom])
            }
        }
        .sheet(isPresented: $showAddHeader) {
            AddHeaderSheet { text, cnt in
                store.addHeader(text, count: cnt, to: currentFarmer)
                Haptics.success()
            }
        }
        .sheet(isPresented: $showExportOptions) {
            ExportOptionsSheet(farmer: farmer, store: store)
        }
    }

    private func binding(for rec: Recommendation) -> Binding<Recommendation> {
        Binding(
            get: {
                currentFarmer.recommendations.first(where: { $0.id == rec.id }) ?? rec
            },
            set: { newValue in
                store.updateRecommendation(newValue, for: currentFarmer)
            }
        )
    }
    
    private func exportSprayProgram(format: ExportFormat) {
        guard let farmerData = store.farmers.first(where: { $0.id == farmer.id }) else { return }
        do {
            _ = try FileExporter.export(farmer: farmerData, format: format)
            // Share functionality will be handled by the sheet
        } catch {
            // Handle error
        }
    }
}

struct HeaderRow: View {
    let header: String
    
    var body: some View {
        HStack {
            Image(systemName: "textformat.abc")
                .foregroundColor(.nexusGreen)
                .font(.title3)
            
            Text(header)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct RecommendationRow: View {
    let index: Int
    @Binding var rec: Recommendation

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("#\(index)")
                    .font(.headline)
                    .foregroundColor(.nexusGreen)
                    .frame(width: 40, alignment: .leading)
                
                Spacer()
                
                Text("Tractor Calibration")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geo in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CalibrationField(title: "TRACTOR", value: $rec.trekker, width: geo.size.width * 0.15)
                        CalibrationField(title: "RAT", value: $rec.rat, width: geo.size.width * 0.12)
                        CalibrationField(title: "REVS", value: $rec.revs, width: geo.size.width * 0.12)
                        CalibrationField(title: "TIME", value: $rec.tyd, width: geo.size.width * 0.15)
                        CalibrationField(title: "PUMP", value: $rec.pomp, width: geo.size.width * 0.12)
                        CalibrationField(title: "PRESSURE", value: $rec.druk, width: geo.size.width * 0.12)
                        CalibrationField(title: "L/HA", value: $rec.ltHa, width: geo.size.width * 0.12)
                    }
                    .padding(.horizontal, 4)
                }
            }
            .frame(height: 60)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

struct CalibrationField: View {
    let title: String
    @Binding var value: String
    let width: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("", text: $value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.caption)
        }
        .frame(width: width)
    }
}

struct ExportButton: View {
    let farmer: Farmer
    @ObservedObject var store: CalibrationStore
    @State private var shareURL: URL?
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        Button {
            exportSprayProgram()
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Export Spray Program")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(.nexusGreen)
        .sheet(item: $shareURL) { url in
            ShareSheet(activityItems: [url])
        }
        .alert("Export Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func exportSprayProgram() {
        guard let farmerData = store.farmers.first(where: { $0.id == farmer.id }) else {
            errorMessage = "Could not find spray program data"
            showError = true
            return
        }
        do {
            let url = try FileExporter.export(farmer: farmerData, format: .csv)
            shareURL = url
            Haptics.success()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            Haptics.error()
        }
    }
}

struct ExportOptionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let farmer: Farmer
    @ObservedObject var store: CalibrationStore
    @State private var shareURL: URL?
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        exportProgram(format: ExportFormat.csv)
                    } label: {
                        HStack {
                            Image(systemName: "tablecells")
                                .foregroundColor(.green)
                            VStack(alignment: .leading) {
                                Text("Export as Excel")
                                    .font(.headline)
                                Text("CSV format for spreadsheet applications")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Button {
                        exportProgram(format: ExportFormat.pdf)
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.red)
                            VStack(alignment: .leading) {
                                Text("Export as PDF")
                                    .font(.headline)
                                Text("Professional document format")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Export Format")
                } footer: {
                    Text("Choose the format that works best for your client")
                }
            }
            .navigationTitle("Export Spray Program")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
            )
            .sheet(item: $shareURL) { url in
                ShareSheet(activityItems: [url])
            }
            .alert("Export Failed", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func exportProgram(format: ExportFormat) {
        guard let farmerData = store.farmers.first(where: { $0.id == farmer.id }) else {
            errorMessage = "Could not find spray program data"
            showError = true
            return
        }
        do {
            let url = try FileExporter.export(farmer: farmerData, format: format)
            shareURL = url
            Haptics.success()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            Haptics.error()
        }
    }
}

struct AddHeaderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var count: Int = 0
    var onAdd: (String, Int) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Header Title", text: $text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } header: {
                    Text("Section Header")
                } footer: {
                    Text("Add a header to organize your spray program (e.g., 'Field 1', 'Crop Type')")
                }
                
                Section {
                    Stepper(value: $count, in: 0...20) {
                        HStack {
                            Text("Tractor Entries")
                            Spacer()
                            Text("\(count)")
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Tractor Entries")
                } footer: {
                    Text("Number of tractor calibration entries to add after this header")
                }
            }
            .navigationTitle("Add Section")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Add") {
                    onAdd(text.trimmingCharacters(in: .whitespaces), count)
                    dismiss()
                }
                .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
            )
        }
    }
}

#Preview {
    FarmerCalibrationView(farmer: Farmer(name: "Sample"), store: CalibrationStore())
}
