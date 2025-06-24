import SwiftUI

struct CategoryCard: View {
    let name: String
    var tint: Color = .nexusGreen

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .foregroundColor(tint)
            Text(name)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(tint.opacity(0.15))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(Text("\(name) folder"))
    }
}
