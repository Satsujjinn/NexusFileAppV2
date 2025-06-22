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
    @Environment(\.editMode) private var editMode

    var body: some View {
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
                    Text(header)
                        .font(.headline)
                } else if let idx = item.1 {
                    RecommendationRow(index: idx, rec: binding(for: rec))
                }
            }
            .onMove { indices, newOffset in
                store.moveRecommendations(at: indices, to: newOffset, for: currentFarmer)
            }
        }
        .navigationTitle(currentFarmer.name)
        .navigationBarItems(
            leading: EditButton(),
            trailing: HStack {
                if editMode?.wrappedValue == .active && !selection.isEmpty {
                    Button("Delete Selected", role: .destructive) {
                        store.deleteRecommendations(with: selection, from: currentFarmer)
                        selection.removeAll()
                    }
                }
                Button("New") {
                    store.addRecommendation(to: currentFarmer)
                }
                Button("Add") { showAddHeader = true }
                SaveButton(farmer: farmer, store: store)
            }
        )
        .safeAreaInset(edge: .bottom) {
            CreateExcelButton(farmer: farmer, store: store)
                .padding([.horizontal, .bottom])
        }
        .sheet(isPresented: $showAddHeader) {
            AddHeaderSheet { text, cnt in
                store.addHeader(text, count: cnt, to: currentFarmer)
            }
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
}

struct RecommendationRow: View {
    let index: Int
    @Binding var rec: Recommendation

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Text("\(index)")
                    .frame(width: 30)

                TextField("TREKKER", text: $rec.trekker)
                    .frame(width: 120)
                TextField("RAT", text: $rec.rat)
                    .frame(width: 60)
                TextField("REVS", text: $rec.revs)
                    .frame(width: 60)
                TextField("TYD OOR TOETSAFSTAND", text: $rec.tyd)
                    .frame(width: 160)
                TextField("POMP", text: $rec.pomp)
                    .frame(width: 60)
                TextField("DRUK", text: $rec.druk)
                    .frame(width: 60)
            }
        }
        .textFieldStyle(BlackBorderTextFieldStyle())
    }
}

struct SaveButton: View {
    let farmer: Farmer
    @ObservedObject var store: CalibrationStore
    @State private var shareURL: URL?
    @State private var showOptions = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false

    var body: some View {
        Button(action: { showOptions = true }) {
            Image(systemName: "tray.and.arrow.down")
        }
        .confirmationDialog("Export Format", isPresented: $showOptions) {
            Button("Excel (.csv)") { export(type: .csv) }
            Button("PDF (.pdf)") { export(type: .pdf) }
        }
        .sheet(item: $shareURL, onDismiss: { showSuccess = true }) { url in
            ShareSheet(activityItems: [url])
        }
        .alert("Export Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Export Saved", isPresented: $showSuccess) {
            Button("OK", role: .cancel) { }
        }
    }

    private enum ExportType { case csv, pdf }

    private func export(type: ExportType) {
        guard let farmerData = store.farmers.first(where: { $0.id == farmer.id }) else {
            errorMessage = FileExporterError.missingFarmer.localizedDescription
            showError = true
            return
        }
        do {
            let url = try FileExporter.export(farmer: farmerData, format: type == .csv ? .csv : .pdf)
            shareURL = url
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        return df
    }()
}

extension UIApplication {
    static func presentShareSheet(url: URL) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else { return }
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        root.present(av, animated: true)
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
                TextField("Header", text: $text)
                Stepper(value: $count, in: 0...20) {
                    Text("Blank Tractors: \(count)")
                }
            }
            .navigationTitle("Add Header")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Add") {
                    onAdd(text, count)
                    dismiss()
                }
                .disabled(text.isEmpty)
            )
        }
    }
}

struct CreateExcelButton: View {
    let farmer: Farmer
    @ObservedObject var store: CalibrationStore
    @State private var shareURL: URL?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false

    var body: some View {
        Button("Create Excel File") {
            export()
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.borderedProminent)
        .sheet(item: $shareURL, onDismiss: { showSuccess = true }) { url in
            ShareSheet(activityItems: [url])
        }
        .alert("Export Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Export Saved", isPresented: $showSuccess) {
            Button("OK", role: .cancel) { }
        }
    }

    private func export() {
        guard let farmerData = store.farmers.first(where: { $0.id == farmer.id }) else {
            errorMessage = FileExporterError.missingFarmer.localizedDescription
            showError = true
            return
        }
        do {
            let url = try FileExporter.export(farmer: farmerData, format: .csv)
            shareURL = url
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    FarmerCalibrationView(farmer: Farmer(name: "Sample"), store: CalibrationStore())
}
