import SwiftUI

/// Enhanced settings screen for app preferences and App Store compliance.
struct GeneralSettingsView: View {
    @AppStorage("showHiddenFiles") private var showHiddenFiles = false
    @AppStorage("enableHaptics") private var enableHaptics = true
    @AppStorage("autoBackup") private var autoBackup = true
    @AppStorage("privacyMode") private var privacyMode = false
    
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    @State private var showingSupport = false
    @State private var showingAbout = false

    var body: some View {
        NavigationStack {
            Form {
                Section("File Management") {
                    Toggle("Show Hidden Files", isOn: $showHiddenFiles)
                    Toggle("Auto Backup", isOn: $autoBackup)
                }
                
                Section("User Experience") {
                    Toggle("Enable Haptics", isOn: $enableHaptics)
                        .onChange(of: enableHaptics) { oldValue, newValue in
                            if newValue {
                                Haptics.selection()
                            }
                        }
                    Toggle("Privacy Mode", isOn: $privacyMode)
                }
                
                Section("Data & Privacy") {
                    Button("Privacy Policy") {
                        showingPrivacyPolicy = true
                    }
                    .foregroundColor(.primary)
                    
                    Button("Terms of Service") {
                        showingTermsOfService = true
                    }
                    .foregroundColor(.primary)
                    
                    Button("Data Export") {
                        exportUserData()
                    }
                    .foregroundColor(.primary)
                    
                    Button("Clear All Data", role: .destructive) {
                        clearAllData()
                    }
                }
                
                Section("Support") {
                    Button("Contact Support") {
                        showingSupport = true
                    }
                    .foregroundColor(.primary)
                    
                    Button("Rate App") {
                        rateApp()
                    }
                    .foregroundColor(.primary)
                    
                    Button("Share App") {
                        shareApp()
                    }
                    .foregroundColor(.primary)
                }
                
                Section("About") {
                    Button("About NexusFileApp") {
                        showingAbout = true
                    }
                    .foregroundColor(.primary)
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showingTermsOfService) {
                TermsOfServiceView()
            }
            .sheet(isPresented: $showingSupport) {
                SupportView()
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
    
    private func exportUserData() {
        // Implementation for data export
        Haptics.success()
    }
    
    private func clearAllData() {
        // Implementation for data clearing with confirmation
        Haptics.warning()
    }
    
    private func rateApp() {
        if let url = URL(string: "https://apps.apple.com/app/id1234567890") {
            UIApplication.shared.open(url)
        }
    }
    
    private func shareApp() {
        let text = "Check out NexusFileApp - the perfect tool for agricultural professionals to manage spray programs and product information!"
        let url = URL(string: "https://apps.apple.com/app/id1234567890")!
        let activityVC = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

#Preview {
    GeneralSettingsView()
}
