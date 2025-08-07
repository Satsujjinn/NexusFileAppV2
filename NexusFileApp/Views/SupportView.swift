import SwiftUI
import MessageUI

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingMailComposer = false
    @State private var showingSafari = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Contact Support") {
                    Button {
                        showingMailComposer = true
                    } label: {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.nexusGreen)
                            VStack(alignment: .leading) {
                                Text("Email Support")
                                    .fontWeight(.medium)
                                Text("Get help with technical issues")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Button {
                        if let url = URL(string: "https://nexusfileapp.com/support") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.nexusGreen)
                            VStack(alignment: .leading) {
                                Text("Online Support")
                                    .fontWeight(.medium)
                                Text("Visit our support website")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section("Help & Documentation") {
                    Button {
                        if let url = URL(string: "https://nexusfileapp.com/help") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.nexusGreen)
                            VStack(alignment: .leading) {
                                Text("User Guide")
                                    .fontWeight(.medium)
                                Text("Learn how to use the app")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Button {
                        if let url = URL(string: "https://nexusfileapp.com/faq") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "list.bullet")
                                .foregroundColor(.nexusGreen)
                            VStack(alignment: .leading) {
                                Text("FAQ")
                                    .fontWeight(.medium)
                                Text("Frequently asked questions")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section("App Information") {
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
                    
                    HStack {
                        Text("Device")
                        Spacer()
                        Text(UIDevice.current.model)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("iOS Version")
                        Spacer()
                        Text(UIDevice.current.systemVersion)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Legal") {
                    Button("Privacy Policy") {
                        // This would be handled by the parent view
                    }
                    .foregroundColor(.primary)
                    
                    Button("Terms of Service") {
                        // This would be handled by the parent view
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Support")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
        .sheet(isPresented: $showingMailComposer) {
            MailComposerView()
        }
    }
}

struct MailComposerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients(["support@nexusfileapp.com"])
        composer.setSubject("NexusFileApp Support Request")
        composer.setMessageBody("""
        Device: \(UIDevice.current.model)
        iOS Version: \(UIDevice.current.systemVersion)
        App Version: 1.0.0
        
        Please describe your issue:
        
        """, isHTML: false)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposerView
        
        init(_ parent: MailComposerView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.dismiss()
        }
    }
}

#Preview {
    SupportView()
} 