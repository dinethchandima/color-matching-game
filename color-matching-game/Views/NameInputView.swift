import SwiftUI

struct NameInputView: View {
    @ObservedObject var game: MemoryGame
    @ObservedObject var scoreManager: ScoreManager
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var showError = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                VStack(spacing: 15) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                    
                    Text("🎉 New High Score!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                    
                    Text("\(game.score) points")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("on \(game.selectedDifficulty.rawValue) difficulty")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                    
                    let previousHigh = scoreManager.getHighScore(forDifficulty: game.selectedDifficulty.rawValue)
                    if previousHigh > 0 {
                        Text("Previous high: \(previousHigh)")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Enter your name:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("Your Name", text: $name)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .font(.title2)
                        .textInputAutocapitalization(.words)
                        .onSubmit {
                            saveScore()
                        }
                        .autocorrectionDisabled()
                }
                
                if showError {
                    Text("Please enter a name")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                VStack(spacing: 15) {
                    Button(action: saveScore) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save Score")
                                .fontWeight(.bold)
                        }
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(name.isEmpty ? Color.gray : Color.green)
                        .cornerRadius(15)
                    }
                    .disabled(name.isEmpty)
                    
                    Button(action: {
                        name = "Anonymous"
                        saveScore()
                    }) {
                        Text("Save as Anonymous")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(40)
            .background(Color(.systemBackground))
            .cornerRadius(25)
            .shadow(radius: 20)
            .padding(40)
        }
        .onAppear {
            print("NameInputView appeared")
            print("Current game state - score: \(game.score), playerName: \(game.playerName)")
        }
    }
    
    private func saveScore() {
        if name.isEmpty {
            showError = true
            return
        }
        
        let timeTaken = game.selectedDifficulty.timeLimit - game.timeRemaining
        let hintsUsed = game.selectedDifficulty.hintCount - game.hintsRemaining
        
        print("Saving score with name: \(name)")
        
        let newScore = GameScore(
            playerName: name,
            score: game.score,
            difficulty: game.selectedDifficulty.rawValue,
            date: Date(),
            timeTaken: timeTaken,
            hintsUsed: hintsUsed
        )
        
        scoreManager.addScore(newScore)
        
        // Update game state
        game.playerName = name
        game.showNameInput = false
        game.gameOver = true
        
        print("Score saved. Player name set to: \(game.playerName)")
        print("Game over flag: \(game.gameOver)")
        print("Show name input flag: \(game.showNameInput)")
    }
}
