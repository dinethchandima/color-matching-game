import SwiftUI
import Foundation
import Combine

enum DifficultyLevel: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var gridSize: Int {
        switch self {
        case .easy: return 3
        case .medium: return 4
        case .hard: return 5
        }
    }
    
    var timeLimit: Int {
        switch self {
        case .easy: return 60
        case .medium: return 45
        case .hard: return 30
        }
    }
    
    var hintCount: Int {
        switch self {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
    
    var totalPairs: Int {
        let totalCards = gridSize * gridSize
        return totalCards / 2
    }
}

class MemoryGame: ObservableObject {
    // MARK: - Published Properties
    @Published var cards: [GameCard] = []
    @Published var score = 0
    @Published var timeRemaining = 60
    @Published var isGameActive = false
    @Published var selectedDifficulty: DifficultyLevel = .easy
    @Published var showDifficultySelection = true
    @Published var gameOver = false
    @Published var moves = 0
    @Published var selectedCards: [GameCard] = []
    @Published var showMatchFeedback = false
    @Published var matchFeedback = ""
    @Published var matchFeedbackColor: Color = .clear
    @Published var hintsRemaining = 0
    @Published var isShowingHint = false
    @Published var hintCards: [GameCard] = []
    @Published var playerName = ""
    @Published var showNameInput = false
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var gameStartTime = Date()
    private let scoreManager = ScoreManager()
    
    private let allColors: [Color] = [
        .red, .blue, .green, .yellow, .orange, .purple,
        .pink, .brown, .cyan, .mint, .teal, .indigo,
        .gray, .black, .white.opacity(0.8)
    ]
    
    // MARK: - Game Logic
    func selectDifficulty(_ difficulty: DifficultyLevel) {
        selectedDifficulty = difficulty
        timeRemaining = difficulty.timeLimit
        hintsRemaining = difficulty.hintCount
        setupGame()
        showDifficultySelection = false
    }
    
    func setupGame() {
          let gridSize = selectedDifficulty.gridSize
          let totalCards = gridSize * gridSize
          let numberOfPairs = totalCards / 2
          
          // Select colors for pairs
          let selectedColors = Array(allColors.shuffled().prefix(numberOfPairs))
          
          // Create pairs
          var newCards: [GameCard] = []
          for color in selectedColors {
              let card1 = GameCard(color: color)
              let card2 = GameCard(color: color)
              newCards.append(contentsOf: [card1, card2])
          }
          
          // If odd number of cards (for 3x3, 5x5), add one bonus card
          if totalCards % 2 == 1 {
              let bonusColor = allColors.filter { !selectedColors.contains($0) }.first ?? .gray
              newCards.append(GameCard(color: bonusColor))
          }
          
          // Shuffle and set cards
          cards = newCards.shuffled()
          
          // Reset game state
          score = 0
          moves = 0
          selectedCards = []
          gameOver = false
          isShowingHint = false
          hintCards = []
          showMatchFeedback = false
          // Don't reset playerName here, it's reset in resetGame()
      }
    
    func startGame() {
        isGameActive = true
        gameStartTime = Date()
        startTimer()
        showAllCardsBriefly()
    }
    
    private func showAllCardsBriefly() {
        // Flip all cards face up
        for i in 0..<cards.count {
            cards[i].isFaceUp = true
        }
        
        // Flip back after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            for i in 0..<self.cards.count {
                self.cards[i].isFaceUp = false
            }
        }
    }
    
    func selectCard(_ card: GameCard) {
        guard isGameActive,
              !card.isFaceUp,
              !card.isMatched,
              selectedCards.count < 2 else { return }
        
        // Cancel any active hint
        if isShowingHint {
            hideHint()
        }
        
        // Find and flip the card
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].isFaceUp = true
            selectedCards.append(cards[index])
            
            // Check for match when 2 cards are selected
            if selectedCards.count == 2 {
                moves += 1
                checkForMatch()
            }
        }
    }
    
    private func checkForMatch() {
        guard selectedCards.count == 2 else { return }
        
        let card1 = selectedCards[0]
        let card2 = selectedCards[1]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            if card1.color == card2.color {
                // Match found
                self.score += 10
                self.matchFeedback = "Match! +10 points"
                self.matchFeedbackColor = .green
                
                // Mark cards as matched
                for i in 0..<self.cards.count {
                    if self.cards[i].id == card1.id || self.cards[i].id == card2.id {
                        self.cards[i].isMatched = true
                        self.cards[i].isFaceUp = true
                    }
                }
                
                // Check if game is complete
                self.checkGameCompletion()
            } else {
                // No match
                self.score = max(0, self.score - 5)
                self.matchFeedback = "No Match! -5 points"
                self.matchFeedbackColor = .red
                
                // Flip cards back
                for i in 0..<self.cards.count {
                    if self.cards[i].id == card1.id || self.cards[i].id == card2.id {
                        self.cards[i].isFaceUp = false
                    }
                }
            }
            
            // Show feedback
            self.showMatchFeedback = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showMatchFeedback = false
            }
            
            // Clear selected cards
            self.selectedCards.removeAll()
        }
    }
    
    private func checkGameCompletion() {
        let matchedCards = cards.filter { $0.isMatched }
        let totalPairs = selectedDifficulty.totalPairs
        
        if matchedCards.count >= totalPairs * 2 {
            // Game completed successfully
            endGame()
            gameOver = true
        }
    }
    
    func useHint() {
        guard hintsRemaining > 0,
              !isShowingHint,
              isGameActive else { return }
        
        // Find unmatched cards
        let unmatchedCards = cards.filter { !$0.isMatched }
        guard unmatchedCards.count >= 2 else { return }
        
        // Find a pair to reveal
        var foundPair: (GameCard, GameCard)? = nil
        
        // First, try to find a complete unmatch pair
        for i in 0..<unmatchedCards.count {
            for j in (i+1)..<unmatchedCards.count {
                if unmatchedCards[i].color == unmatchedCards[j].color {
                    foundPair = (unmatchedCards[i], unmatchedCards[j])
                    break
                }
            }
            if foundPair != nil { break }
        }
        
        // If no complete pair found, show any two cards
        if foundPair == nil && unmatchedCards.count >= 2 {
            foundPair = (unmatchedCards[0], unmatchedCards[1])
        }
        
        guard let (card1, card2) = foundPair else { return }
        
        // Use a hint
        hintsRemaining -= 1
        isShowingHint = true
        hintCards = [card1, card2]
        
        // Show the hint cards
        for i in 0..<cards.count {
            if cards[i].id == card1.id || cards[i].id == card2.id {
                cards[i].isFaceUp = true
            }
        }
        
        // Hide hint after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.hideHint()
        }
    }
    
    func hideHint() {
        guard isShowingHint else { return }
        
        // Hide the hint cards if they're not matched
        for i in 0..<cards.count {
            if hintCards.contains(where: { $0.id == cards[i].id }) && !cards[i].isMatched {
                cards[i].isFaceUp = false
            }
        }
        
        isShowingHint = false
        hintCards = []
    }
    
    func shouldShowNameInput() -> Bool {
           // We'll check this elsewhere, method is simplified
           return false
       }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.endGame()
                self.gameOver = true
            }
        }
    }
    
   
    func endGame() {
            isGameActive = false
            timer?.invalidate()
            timer = nil
            
            // Show name input if score is high enough
            let highScore = scoreManager.getHighScore(forDifficulty: selectedDifficulty.rawValue)
            if score > highScore || highScore == 0 {
                showNameInput = true
            } else {
                gameOver = true
            }
        print("Game ended with score: \(score)")
        }
    func resetGame() {
        endGame()
        hintsRemaining = selectedDifficulty.hintCount
        setupGame()
        timeRemaining = selectedDifficulty.timeLimit
        playerName = "" // Reset player name
        showNameInput = false // Reset name input flag
        startGame()
    }
       
      
       
    func returnToMenu() {
          endGame()
          playerName = "" // Reset player name
          showNameInput = false // Reset name input flag
          showDifficultySelection = true
          gameOver = false
      }
    
        func saveScore() {
            let timeTaken = selectedDifficulty.timeLimit - timeRemaining
            let hintsUsed = selectedDifficulty.hintCount - hintsRemaining
            
            let newScore = GameScore(
                playerName: playerName.isEmpty ? "Anonymous" : playerName,
                score: score,
                difficulty: selectedDifficulty.rawValue,
                date: Date(),
                timeTaken: timeTaken,
                hintsUsed: hintsUsed
            )
            
            scoreManager.addScore(newScore)
            showNameInput = false
            gameOver = true
        }
        
        func getHighScore() -> Int {
            return scoreManager.getHighScore(forDifficulty: selectedDifficulty.rawValue)
        }
        
    
   
}
