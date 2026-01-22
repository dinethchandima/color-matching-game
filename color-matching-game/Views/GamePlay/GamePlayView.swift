import SwiftUI

struct GamePlayView: View {
    @ObservedObject var game: MemoryGame
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 10), count: game.selectedDifficulty.gridSize)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Game Header
            GameHeaderView(game: game)
            
            // Game Grid
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(game.cards) { card in
                    GameCardView(card: card) {
                        game.selectCard(card)
                    }
                }
            }
            .padding(.horizontal)
            
            // Game Stats with Hint Button
            HStack {
                StatBox(title: "Moves", value: "\(game.moves)")
                
                // Hint Button
                HintButton(game: game)
                
                StatBox(title: "Time", value: "\(game.timeRemaining)s")
            }
            .padding(.horizontal)
            
            // Pairs Remaining
            HStack {
                StatBox(
                    title: "Pairs Left",
                    value: "\(game.selectedDifficulty.totalPairs - (game.cards.filter { $0.isMatched }.count / 2))"
                )
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Control Buttons
            HStack(spacing: 20) {
                ControlButton(
                    title: "Reset",
                    icon: "arrow.counterclockwise",
                    color: .orange,
                    action: {
                        game.resetGame()
                    }
                )
                
                ControlButton(
                    title: "Menu",
                    icon: "house.fill",
                    color: .blue,
                    action: {
                        game.returnToMenu()
                    }
                )
            }
            .padding(.horizontal)
            
            // Hint Active Indicator
            if game.isShowingHint {
                HintActiveIndicator()
            }
            
            // Match Feedback
            if game.showMatchFeedback {
                MatchFeedbackView(message: game.matchFeedback, color: game.matchFeedbackColor)
            }
        }
        .padding(.vertical)
        .onAppear {
            if !game.isGameActive && !game.gameOver {
                game.startGame()
            }
        }
    }
}
