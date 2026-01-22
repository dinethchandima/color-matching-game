import SwiftUI

struct ColorItemView: View {
    let colorItem: ColorItem
    let onSelect: (ColorItem) -> Void
    let isSelected: Bool
    
    var body: some View {
        Button(action: {
            onSelect(colorItem)
        }) {
            VStack(spacing: 10) {
                // Color swatch
                RoundedRectangle(cornerRadius: 15)
                    .fill(colorItem.color)
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 4 : 2)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Color name
                Text(colorItem.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
