import SwiftUI

/// Simple settings screen for app preferences.
struct GeneralSettingsView: View {
    @AppStorage("useICloudSync") private var useICloudSync = true
    @AppStorage("showHiddenFiles") private var showHiddenFiles = false

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Use iCloud Sync", isOn: $useICloudSync)
                Toggle("Show Hidden Files", isOn: $showHiddenFiles)
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    GeneralSettingsView()
}
