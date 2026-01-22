import SwiftUI

struct MemoryGameView: View {
    @StateObject private var game = MemoryGame()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if game.showDifficultySelection {
                    DifficultySelectionView(game: game)
                } else if game.gameOver {
                    GameOverView(game: game)
                } else {
                    GamePlayView(game: game)
                }
            }
            .navigationTitle("Memory Match")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
