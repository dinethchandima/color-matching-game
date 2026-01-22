import SwiftUI

struct GameOverView: View {
    @ObservedObject var game: MemoryGame
    @ObservedObject var scoreManager: ScoreManager
    @State private var showScoreboard = false
    
    var hintsUsed: Int {
        game.selectedDifficulty.hintCount - game.hintsRemaining
    }
    
    var highScore: Int {
        scoreManager.getHighScore(forDifficulty: game.selectedDifficulty.rawValue)
    }
    
    var isNewHighScore: Bool {
        return game.score > highScore || highScore == 0
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer()
                
                // Game Result
                VStack(spacing: 20) {
                    Image(systemName: game.timeRemaining == 0 ? "clock.badge.xmark" : "trophy.fill")
                        .font(.system(size: 80))
                        .foregroundColor(game.timeRemaining == 0 ? .red : .yellow)
                    
                    Text(game.timeRemaining == 0 ? "Time's Up!" : "You Win!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(game.timeRemaining == 0 ? .red : .green)
                    
                    if isNewHighScore && game.playerName.isEmpty {
                        Text("🎉 New High Score!")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.yellow)
                    }
                    
                    Text(game.timeRemaining == 0 ? "Better luck next time!" : "Excellent Memory!")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                // Game Stats
                VStack(spacing: 25) {
                    GameStatRow(title: "Your Score", value: "\(game.score)", icon: "star.fill", color: .blue)
                    
                    GameStatRow(
                        title: "High Score",
                        value: "\(highScore)",
                        icon: "trophy.fill",
                        color: isNewHighScore ? .yellow : .orange
                    )
                    
                    if !game.playerName.isEmpty && isNewHighScore {
                        GameStatRow(
                            title: "Record Holder",
                            value: game.playerName,
                            icon: "person.fill",
                            color: .green
                        )
                    }
                    
                    GameStatRow(title: "Moves", value: "\(game.moves)", icon: "arrow.right.arrow.left", color: .purple)
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
                
                // Action Buttons
                VStack(spacing: 15) {
                    PrimaryButton(
                        title: "Play Again",
                        icon: "arrow.clockwise",
                        color: .green,
                        action: {
                            // Clear the player name before resetting
                            game.playerName = ""
                            game.showNameInput = false
                            game.resetGame()
                        }
                    )
                    
                    SecondaryButton(
                        title: "View Scoreboard",
                        icon: "trophy.fill",
                        color: .yellow,
                        action: {
                            showScoreboard = true
                        }
                    )
                    .sheet(isPresented: $showScoreboard) {
                        ScoreboardView(scoreManager: scoreManager)
                    }
                    
                    SecondaryButton(
                        title: "Change Difficulty",
                        icon: "slider.horizontal.3",
                        color: .blue,
                        action: {
                            game.returnToMenu()
                        }
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical, 40)
        }
        .onAppear {
            print("GameOverView appeared")
            print("Player name: \(game.playerName)")
            print("Show name input: \(game.showNameInput)")
            print("Game score: \(game.score)")
            print("High score: \(highScore)")
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
