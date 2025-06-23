import SwiftUI

struct ClientAanbevelingView: View {
    let client: Client
    @ObservedObject var store: AanbevelingStore
    /// Latest copy of the client from the store if available
    private var currentClient: Client {
        store.clients.first(where: { $0.id == client.id }) ?? client
    }
    @State private var showAddHeader = false
    @State private var selection = Set<UUID>()
    @Environment(\.editMode) private var editMode

    var body: some View {
        List(selection: $selection) {
            let recs = store.clients.first(where: { $0.id == client.id })?.aanbevelings ?? []
            let enumerated: [(Aanbeveling, Int?)] = {
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
                    AanbevelingRow(index: idx, rec: binding(for: rec))
                }
            }
            .onMove { indices, newOffset in
                store.moveAanbevelings(at: indices, to: newOffset, for: currentClient)
            }
        }
        .navigationTitle(currentClient.name)
        .navigationBarItems(
            leading: EditButton(),
            trailing: HStack {
                if editMode?.wrappedValue == .active && !selection.isEmpty {
                    Button("Delete Selected", role: .destructive) {
                        store.deleteAanbevelings(with: selection, from: currentClient)
                        selection.removeAll()
                    }
                }
                Button("New") {
                    store.addAanbeveling(to: currentClient)
                }
                Button("Add") { showAddHeader = true }
                SaveButton(client: client, store: store)
            }
        )
        .safeAreaInset(edge: .bottom) {
            CreateExcelButton(client: client, store: store)
                .padding([.horizontal, .bottom])
        }
        .sheet(isPresented: $showAddHeader) {
            AddHeaderSheet { text, cnt in
                store.addHeader(text, count: cnt, to: currentClient)
            }
        }
    }

    private func binding(for rec: Aanbeveling) -> Binding<Aanbeveling> {
        Binding(
            get: {
                currentClient.aanbevelings.first(where: { $0.id == rec.id }) ?? rec
            },
            set: { newValue in
                store.updateAanbeveling(newValue, for: currentClient)
            }
        )
    }
}

struct AanbevelingRow: View {
    let index: Int
    @Binding var rec: Aanbeveling

    var body: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Text("\(index)")
                        .frame(width: 30)

                    let total = geo.size.width - 30
                    let gewasWidth = max(total * 0.22, 120)
                    let smallWidth = max(total * 0.11, 50)
                    let aktiefWidth = max(total * 0.23, 130)

                    TextField("GEWAS", text: $rec.gewas)
                        .frame(width: gewasWidth)
                    TextField("TEKEN", text: $rec.teken)
                        .frame(width: smallWidth)
                    TextField("PRODUK", text: $rec.produk)
                        .frame(width: smallWidth)
                    TextField("AKTIEF", text: $rec.aktief)
                        .frame(width: aktiefWidth)
                    TextField("DOSIS/LT", text: $rec.dosisLt)
                        .frame(width: smallWidth)
                    TextField("DOSIS/TENK", text: $rec.dosisTenk)
                        .frame(width: smallWidth)
                    TextField("OHP", text: $rec.ohp)
                        .frame(width: smallWidth)
                }
            }
        }
        .frame(height: 40)
        .textFieldStyle(BlackBorderTextFieldStyle())
    }
}

struct SaveButton: View {
    let client: Client
    @ObservedObject var store: AanbevelingStore
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
        guard let clientData = store.clients.first(where: { $0.id == client.id }) else {
            errorMessage = FileExporterError.missingFarmer.localizedDescription
            showError = true
            return
        }
        do {
            let url = try AanbevelingExporter.export(client: clientData, format: type == .csv ? .csv : .pdf)
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
                    Text("Blank Entries: \(count)")
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
    let client: Client
    @ObservedObject var store: AanbevelingStore
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
        .tint(.blue)
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
        guard let clientData = store.clients.first(where: { $0.id == client.id }) else {
            errorMessage = FileExporterError.missingFarmer.localizedDescription
            showError = true
            return
        }
        do {
            let url = try AanbevelingExporter.export(client: clientData, format: .csv)
            shareURL = url
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    ClientAanbevelingView(client: Client(name: "Sample"), store: AanbevelingStore())
}
