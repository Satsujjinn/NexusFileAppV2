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
                ExportButton(farmer: farmer)
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

struct ExportButton: View {
    let farmer: Farmer

    var body: some View {
        Button {
            export()
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
    }

    private func export() {
        // Placeholder export implementation
        let template = Bundle.main.url(forResource: "Trekker-Inligting-Template", withExtension: "xlsx")
        let filename = "Trekker Inligting_\(farmer.name)_\(Self.dateFormatter.string(from: Date())).xlsx"
        if let template, let docs = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            let dest = docs.appendingPathComponent(filename)
            try? FileManager.default.copyItem(at: template, to: dest)
            UIApplication.presentShareSheet(url: dest)
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
