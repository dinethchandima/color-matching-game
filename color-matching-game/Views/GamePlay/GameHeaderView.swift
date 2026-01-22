import SwiftUI

struct GameHeaderView: View {
    @ObservedObject var game: MemoryGame
    @EnvironmentObject var scoreManager: ScoreManager
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(game.score)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text("Difficulty")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(game.selectedDifficulty.rawValue)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(getDifficultyColor(game.selectedDifficulty))
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(game.timeRemaining)s")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(getTimeColor(game.timeRemaining))
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            
            HStack {
                Text("High Score: \(scoreManager.getHighScore(forDifficulty: game.selectedDifficulty.rawValue))")
                    .font(.subheadline)
                    .foregroundColor(.yellow)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("Tap two cards to find matching colors")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            if game.hintsRemaining > 0 {
                Text("Tap the 💡 button for a hint!")
                    .font(.subheadline)
                    .foregroundColor(.yellow)
                    .padding(.horizontal)
            }
        }
    }
    
    private func getDifficultyColor(_ difficulty: DifficultyLevel) -> Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    private func getTimeColor(_ time: Int) -> Color {
        switch time {
        case ...10: return .red
        case 11...30: return .orange
        default: return .green
        }
    }
}
