import SwiftUI

struct MemoryGameView: View {
    @StateObject private var game = MemoryGame()
    @StateObject private var scoreManager = ScoreManager()
    @State private var showScoreboard = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                // Main view controller
                if game.showDifficultySelection {
                    DifficultySelectionView(game: game)
                } else if game.gameOver {
                    GameOverView(game: game, scoreManager: scoreManager)
                } else if game.showNameInput && shouldShowNameInput() {
                    NameInputView(game: game, scoreManager: scoreManager)
                } else {
                    GamePlayView(game: game)
                }
            }
            .navigationTitle("Memory Match")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showScoreboard = true
                    }) {
                        Image(systemName: "trophy.fill")
                            .font(.title3)
                            .foregroundColor(.yellow)
                    }
                }
            }
            .sheet(isPresented: $showScoreboard) {
                ScoreboardView(scoreManager: scoreManager)
            }
            .environmentObject(scoreManager)
        }
    }
    
    private func shouldShowNameInput() -> Bool {
        let highScore = scoreManager.getHighScore(forDifficulty: game.selectedDifficulty.rawValue)
        let isNewHigh = game.score > highScore || highScore == 0
        
        print("Should show name input?")
        print("- Game score: \(game.score)")
        print("- High score: \(highScore)")
        print("- Is new high: \(isNewHigh)")
        print("- Player name: \(game.playerName)")
        
        // Only show name input if:
        // 1. It's a new high score AND
        // 2. We haven't already saved a name for this game session
        return isNewHigh && game.playerName.isEmpty
    }
}
