import SwiftUI

struct HintButton: View {
    @ObservedObject var game: MemoryGame
    
    var body: some View {
        Button(action: game.useHint) {
            VStack(spacing: 5) {
                Image(systemName: "lightbulb.fill")
                    .font(.title3)
                    .foregroundColor(game.hintsRemaining > 0 ? .yellow : .gray)
                
                Text("\(game.hintsRemaining)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(game.hintsRemaining > 0 ? .yellow : .gray)
                
                Text("Hints")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(game.hintsRemaining > 0 ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(game.hintsRemaining > 0 ? Color.yellow : Color.gray, lineWidth: 2)
            )
            .shadow(color: game.hintsRemaining > 0 ? Color.yellow.opacity(0.2) : Color.clear, radius: 3, x: 0, y: 2)
        }
        .disabled(game.hintsRemaining == 0 || game.isShowingHint || !game.isGameActive)
        .scaleEffect(game.hintsRemaining > 0 ? 1.0 : 0.95)
        .animation(.spring(response: 0.3), value: game.hintsRemaining)
    }
}
