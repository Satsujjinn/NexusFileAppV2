import SwiftUI

struct FarmerCalibrationView: View {
    let farmer: Farmer
    @ObservedObject var store: CalibrationStore
    @State private var showAddHeader = false

    var body: some View {
        List {
            let recs = store.farmers.first(where: { $0.id == farmer.id })?.recommendations ?? []
            ForEach(Array(recs.enumerated()), id: \.element.id) { index, rec in
                if let header = rec.header {
                    Text(header)
                        .font(.headline)
                } else {
                    RecommendationRow(index: index + 1, rec: binding(for: rec))
                }
            }
            .onDelete { indexSet in
                store.deleteRecommendations(at: indexSet, from: farmer)
            }
            .onMove { indices, newOffset in
                store.moveRecommendations(at: indices, to: newOffset, for: farmer)
            }
        }
        .navigationTitle(farmer.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("New Trekker") {
                    store.addRecommendation(to: farmer)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add Header") { showAddHeader = true }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                SaveButton(farmer: farmer, store: store)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .safeAreaInset(edge: .bottom) {
            CreateExcelButton(farmer: farmer, store: store)
                .padding([.horizontal, .bottom])
        }
        .sheet(isPresented: $showAddHeader) {
            AddHeaderSheet { text in
                store.addHeader(text, to: farmer)
            }
        }
    }

    private func binding(for rec: Recommendation) -> Binding<Recommendation> {
        Binding(
            get: {
                store.farmers.first(where: { $0.id == farmer.id })?.recommendations.first(where: { $0.id == rec.id }) ?? rec
            },
            set: { newValue in
                store.updateRecommendation(newValue, for: farmer)
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

    var body: some View {
        Button(action: { showOptions = true }) {
            Image(systemName: "tray.and.arrow.down")
        }
        .confirmationDialog("Export Format", isPresented: $showOptions) {
            Button("Excel (.csv)") { export(type: .csv) }
            Button("PDF (.pdf)") { export(type: .pdf) }
        }
        .sheet(item: $shareURL) { url in
            ShareSheet(activityItems: [url])
        }
        .alert("Export Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
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
    var onAdd: (String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Header", text: $text)
            }
            .navigationTitle("Add Header")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(text)
                        dismiss()
                    }
                    .disabled(text.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct CreateExcelButton: View {
    let farmer: Farmer
    @ObservedObject var store: CalibrationStore
    @State private var shareURL: URL?
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        Button("Create Excel File") {
            export()
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.borderedProminent)
        .sheet(item: $shareURL) { url in
            ShareSheet(activityItems: [url])
        }
        .alert("Export Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
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
