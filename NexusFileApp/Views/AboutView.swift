import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // App Icon and Name
                    VStack(spacing: 16) {
                        Image(systemName: "tractor.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.nexusGreen)
                        
                        Text("NexusFileApp")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Agricultural File Management")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Version Info
                    VStack(spacing: 8) {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                        }
                        
                        HStack {
                            Text("Build")
                            Spacer()
                            Text("1")
                        }
                        
                        HStack {
                            Text("Release Date")
                            Spacer()
                            Text("January 2025")
                        }
                    }
                    .font(.subheadline)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("NexusFileApp is a specialized file management application designed for agricultural professionals. It helps you organize spray programs, product labels, safety data sheets, and technical documentation for your clients.")
                        
                        Text("Features include:")
                            .fontWeight(.medium)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FeatureRow(icon: "tractor.fill", text: "Spray Program Management")
                            FeatureRow(icon: "doc.fill", text: "Document Organization")
                            FeatureRow(icon: "square.and.arrow.up", text: "File Sharing")
                            FeatureRow(icon: "magnifyingglass", text: "Advanced Search")
                            FeatureRow(icon: "eye.fill", text: "File Preview")
                        }
                    }
                    
                    // Developer Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Developer")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Developed with ❤️ for the agricultural community")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Built with SwiftUI and following Apple's Human Interface Guidelines for the best possible user experience.")
                    }
                    
                    // Links
                    VStack(spacing: 12) {
                        Button {
                            if let url = URL(string: "https://nexusfileapp.com") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "globe")
                                Text("Visit Website")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.nexusGreen)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button {
                            if let url = URL(string: "https://nexusfileapp.com/privacy") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "hand.raised.fill")
                                Text("Privacy Policy")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                        }
                    }
                    
                    // Copyright
                    Text("© 2025 NexusFileApp. All rights reserved.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.nexusGreen)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    AboutView()
} 