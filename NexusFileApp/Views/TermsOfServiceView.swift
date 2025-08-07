import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Terms of Service")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Last updated: January 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Group {
                        Text("Acceptance of Terms")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("By downloading and using NexusFileApp, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app.")
                        
                        Text("App Description")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("NexusFileApp is a file management application designed for agricultural professionals to organize spray programs, product labels, and technical documentation.")
                        
                        Text("User Responsibilities")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("You are responsible for: \n• Maintaining the security of your device and data\n• Ensuring compliance with local agricultural regulations\n• Backing up your important data\n• Using the app in accordance with applicable laws")
                        
                        Text("Data and Privacy")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Your data is stored locally on your device. We do not collect, store, or transmit your personal information. Please review our Privacy Policy for more details.")
                        
                        Text("Intellectual Property")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("NexusFileApp and its content are protected by copyright and other intellectual property laws. You may not copy, modify, or distribute the app without permission.")
                        
                        Text("Limitation of Liability")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("NexusFileApp is provided 'as is' without warranties. We are not liable for any damages arising from the use of the app or loss of data.")
                        
                        Text("Updates and Changes")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("We may update these terms from time to time. Continued use of the app after changes constitutes acceptance of the new terms.")
                        
                        Text("Contact Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("For questions about these terms, contact us at legal@nexusfileapp.com")
                    }
                }
                .padding()
            }
            .navigationTitle("Terms of Service")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

#Preview {
    TermsOfServiceView()
} 