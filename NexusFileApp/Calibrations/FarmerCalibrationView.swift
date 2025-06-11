import SwiftUI

struct FarmerCalibrationView: View {
    let farmer: Farmer
    @ObservedObject var store: CalibrationStore

    var body: some View {
        List {
            ForEach(store.farmers.first(where: { $0.id == farmer.id })?.recommendations.sorted { $0.date > $1.date } ?? []) { rec in
                RecommendationRow(rec: binding(for: rec))
            }
        }
        .navigationTitle(farmer.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add Recommendation") {
                    store.addRecommendation(to: farmer)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                SaveButton(farmer: farmer, store: store)
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
        VStack(alignment: .leading) {
            HStack {
                TextField("TREKKER", text: $rec.trekker)
                TextField("RAT", text: $rec.rat)
                TextField("REVS", text: $rec.revs)
            }
            HStack {
                TextField("TYD OOR TOETSAFSTAND", text: $rec.tyd)
                TextField("POMP", text: $rec.pomp)
                TextField("DRUK", text: $rec.druk)
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

#Preview {
    FarmerCalibrationView(farmer: Farmer(name: "Sample"), store: CalibrationStore())
}
