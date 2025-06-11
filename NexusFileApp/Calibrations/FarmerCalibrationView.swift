import SwiftUI

struct FarmerCalibrationView: View {
    let farmer: Farmer
    @ObservedObject var store: CalibrationStore
    @State private var showAddHeader = false

    var body: some View {
        List {
            ForEach(store.farmers.first(where: { $0.id == farmer.id })?.recommendations ?? []) { rec in
                if let header = rec.header {
                    Text(header)
                        .font(.headline)
                } else {
                    RecommendationRow(rec: binding(for: rec))
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
    @Binding var rec: Recommendation

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                DatePicker(
                    "",
                    selection: $rec.date,
                    displayedComponents: .date
                )
                .labelsHidden()
                .frame(width: 110)

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
        .textFieldStyle(.roundedBorder)
    }
}

struct SaveButton: View {
    let farmer: Farmer
    @ObservedObject var store: CalibrationStore
    @State private var shareURL: URL?
    @State private var showOptions = false

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
    }

    private enum ExportType { case csv, pdf }

    private func export(type: ExportType) {
        let folder = SharedFileManager.shared.documentsURL
            .appendingPathComponent("Calibration Sheets", isDirectory: true)
            .appendingPathComponent(farmer.name, isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        var filename = "Trekker Inligting_\(farmer.name)_\(Self.dateFormatter.string(from: Date()))"
        switch type {
        case .csv:
            filename += ".csv"
        case .pdf:
            filename += ".pdf"
        }
        let fileURL = folder.appendingPathComponent(filename)
        if let farmerData = store.farmers.first(where: { $0.id == farmer.id }) {
            switch type {
            case .csv:
                try? CSVExporter.export(farmer: farmerData, to: fileURL)
            case .pdf:
                try? PDFExporter.export(farmer: farmerData, to: fileURL)
            }
            shareURL = fileURL
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

#Preview {
    FarmerCalibrationView(farmer: Farmer(name: "Sample"), store: CalibrationStore())
}
