import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy Policy")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Last updated: January 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Group {
                        Text("Information We Collect")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("NexusFileApp collects and stores your agricultural documents and spray programs locally on your device. We do not collect, store, or transmit any personal information to external servers.")
                        
                        Text("File Storage")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("All your files are stored locally on your device. We do not have access to your files or data.")
                        
                        Text("Analytics")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("We do not collect analytics data or track your usage. All app functionality is performed locally on your device.")
                        
                        Text("Third-Party Services")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("NexusFileApp does not use any third-party services that collect personal information.")
                        
                        Text("Data Retention")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Your data is retained as long as you keep it in the app. You can delete all data at any time through the app settings.")
                        
                        Text("Contact Us")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("If you have any questions about this privacy policy, please contact us at privacy@nexusfileapp.com")
                    }
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

#Preview {
    PrivacyPolicyView()
} 