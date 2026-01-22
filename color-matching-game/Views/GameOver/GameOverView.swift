import SwiftUI

struct GameOverView: View {
    @ObservedObject var game: MemoryGame
    
    var hintsUsed: Int {
        game.selectedDifficulty.hintCount - game.hintsRemaining
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 20) {
                    Image(systemName: game.timeRemaining == 0 ? "clock.badge.xmark" : "trophy.fill")
                        .font(.system(size: 80))
                        .foregroundColor(game.timeRemaining == 0 ? .red : .yellow)
                    
                    Text(game.timeRemaining == 0 ? "Time's Up!" : "You Win!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(game.timeRemaining == 0 ? .red : .green)
                    
                    Text(game.timeRemaining == 0 ? "Better luck next time!" : "Excellent Memory!")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 25) {
                    GameStatRow(title: "Final Score", value: "\(game.score)", icon: "star.fill", color: .yellow)
                    GameStatRow(title: "Moves", value: "\(game.moves)", icon: "arrow.right.arrow.left", color: .blue)
                    GameStatRow(title: "Hints Used", value: "\(hintsUsed)/\(game.selectedDifficulty.hintCount)", icon: "lightbulb.fill", color: .purple)
                    GameStatRow(title: "Difficulty", value: game.selectedDifficulty.rawValue, icon: "chart.bar.fill", color: getDifficultyColor(game.selectedDifficulty))
                    GameStatRow(title: "Time Left", value: "\(game.timeRemaining)s", icon: "clock.fill", color: .orange)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 15) {
                    PrimaryButton(
                        title: "Play Again",
                        icon: "arrow.clockwise",
                        color: .green,
                        action: {
                            game.resetGame()
                            game.startGame()
                            game.gameOver = false
                        }
                    )
                    
                    SecondaryButton(
                        title: "Change Difficulty",
                        icon: "slider.horizontal.3",
                        color: .blue,
                        action: game.returnToMenu
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical, 40)
        }
    }
    
    private func getDifficultyColor(_ difficulty: DifficultyLevel) -> Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}
