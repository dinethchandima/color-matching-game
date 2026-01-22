import SwiftUI

struct DifficultySelectionView: View {
    @ObservedObject var game: MemoryGame
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Select Difficulty")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 40)
                
                VStack(spacing: 20) {
                    ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                        Button(action: {
                            game.selectDifficulty(difficulty)
                        }) {
                            DifficultyCardView(difficulty: difficulty)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 15) {
                    DifficultyInfoRow(
                        level: "Easy",
                        gridSize: "3×3 Grid",
                        time: "60 seconds",
                        hints: "1 hint",
                        description: "9 cards, 4 pairs"
                    )
                    
                    DifficultyInfoRow(
                        level: "Medium",
                        gridSize: "4×4 Grid",
                        time: "45 seconds",
                        hints: "2 hints",
                        description: "16 cards, 8 pairs"
                    )
                    
                    DifficultyInfoRow(
                        level: "Hard",
                        gridSize: "5×5 Grid",
                        time: "30 seconds",
                        hints: "3 hints",
                        description: "25 cards, 12 pairs + 1 bonus"
                    )
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                Text("Match pairs of colors before time runs out!")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 40)
            }
        }
    }
}
