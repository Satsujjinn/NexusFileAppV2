import SwiftUI

struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.nexusGreen)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading: \(message)")
    }
}

struct ErrorView: View {
    let error: AppError
    let retryAction: () -> Void
    @State private var showingSupport = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)
                .accessibilityHidden(true)
            
            VStack(spacing: 12) {
                Text(error.errorDescription ?? "An error occurred")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .accessibilityLabel("Recovery suggestion: \(suggestion)")
                }
                
                if error.shouldShowSupportContact {
                    Text("Error Code: \(error.errorCode)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Error code \(error.errorCode)")
                }
            }
            
            VStack(spacing: 12) {
                if error.isUserRecoverable {
                    Button("Try Again") {
                        retryAction()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.nexusGreen)
                    .accessibilityLabel("Try again")
                }
                
                if error.shouldShowSupportContact {
                    Button("Contact Support") {
                        showingSupport = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                    .accessibilityLabel("Contact support for help")
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error occurred: \(error.errorDescription ?? "Unknown error")")
        .sheet(isPresented: $showingSupport) {
            SupportView()
        }
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    var actionButton: (title: String, action: () -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionButton = actionButton {
                Button(actionButton.title) {
                    actionButton.action()
                }
                .buttonStyle(.borderedProminent)
                .tint(.nexusGreen)
                .accessibilityLabel(actionButton.title)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(message)")
    }
} 