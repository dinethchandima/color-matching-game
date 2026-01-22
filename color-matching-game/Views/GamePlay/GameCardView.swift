import SwiftUI

struct GameCardView: View {
    let card: GameCard
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: 10)
                    .fill(card.isFaceUp ? card.color : Color(.systemGray4))
                    .frame(height: 70)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(card.isMatched ? Color.green : Color.clear, lineWidth: 3)
                    )
                
                // Card content
                if card.isFaceUp {
                    if card.isMatched {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                } else {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
            .scaleEffect(card.isFaceUp ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: card.isFaceUp)
        }
        .disabled(card.isMatched || card.isFaceUp)
        .buttonStyle(PlainButtonStyle())
    }
}
