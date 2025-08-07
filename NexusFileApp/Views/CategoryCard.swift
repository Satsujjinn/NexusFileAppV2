import SwiftUI

struct CategoryCard: View {
    let name: String
    var tint: Color = .nexusGreen
    var icon: String = "folder.fill"

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .foregroundColor(tint)
            Text(name)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
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

struct CategoryCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CategoryCard(name: "Spray Programs", tint: .nexusGreen, icon: "tractor.fill")
            CategoryCard(name: "Documents", tint: .blue, icon: "doc.fill")
            CategoryCard(name: "Images", tint: .purple, icon: "photo.fill")
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
