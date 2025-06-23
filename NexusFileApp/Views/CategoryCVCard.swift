import SwiftUI

/// Card view used in collection layouts to represent a category.
struct CategoryCVCard: View {
    let name: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .foregroundColor(.nexusGreen)
            Text(name)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color.nexusGreen.opacity(0.15))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(Text("\(name) folder"))
    }
}

#Preview {
    CategoryCVCard(name: "Sample")
}
