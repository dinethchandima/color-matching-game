import SwiftUI
import Foundation
import Combine

struct GameCard: Identifiable, Equatable {
    let id = UUID()
    let color: Color
    var isFaceUp: Bool = false
    var isMatched: Bool = false
    
    static func == (lhs: GameCard, rhs: GameCard) -> Bool {
        return lhs.color == rhs.color
    }
}

enum DifficultyLevel: String, CaseIterable, Codable {
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
        case .easy: return 15
        case .medium: return 30
        case .hard: return 45
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
import SwiftUI

enum GameType: String, CaseIterable {
    case memoryMatch = "Memory Match"
    case colorMatch = "Color Match"
    
    var icon: String {
        switch self {
        case .memoryMatch: return "brain.head.profile"
        case .colorMatch: return "paintpalette.fill"
        }
    }
    
    var description: String {
        switch self {
        case .memoryMatch: return "Test your memory skills by matching pairs!"
        case .colorMatch: return "Find the correct color as fast as you can!"
        }
    }
}



struct HighScore: Identifiable, Codable, Comparable {
    let id = UUID()
    let score: Int
    let difficulty: DifficultyLevel
    let date: Date
    let timeLeft: Int
    let moves: Int
    let hintsUsed: Int
    
    static func < (lhs: HighScore, rhs: HighScore) -> Bool {
        return lhs.score < rhs.score
    }
    
    static func == (lhs: HighScore, rhs: HighScore) -> Bool {
        return lhs.id == rhs.id
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
    @Published var highScores: [HighScore] = []
    @Published var showHighScores = false
    @Published var newHighScoreAchieved = false
    @Published var currentRound: Int = 1
    
    // MARK: - Private Properties
    private var timer: Timer?
    private let allColors: [Color] = [
        .red, .blue, .green, .yellow, .orange, .purple,
        .pink, .brown, .cyan, .mint, .teal, .indigo,
        .gray, .black, .white.opacity(0.8)
    ]
    private let highScoresKey = "memoryGameHighScores"
    
    // MARK: - Initializer
    init() {
        loadHighScores()
    }
    
    // MARK: - High Score Management
    private func loadHighScores() {
        if let data = UserDefaults.standard.data(forKey: highScoresKey) {
            if let decoded = try? JSONDecoder().decode([HighScore].self, from: data) {
                highScores = decoded
                return
            }
        }
        highScores = []
    }
    
    private func saveHighScores() {
        if let encoded = try? JSONEncoder().encode(highScores) {
            UserDefaults.standard.set(encoded, forKey: highScoresKey)
        }
    }
    
    func addHighScore(timeLeft: Int, hintsUsed: Int) {
        let newScore = HighScore(
            score: score,
            difficulty: selectedDifficulty,
            date: Date(),
            timeLeft: timeLeft,
            moves: moves,
            hintsUsed: hintsUsed
        )
        
        // Check if it's a new high score for this difficulty
        let scoresForDifficulty = highScores.filter { $0.difficulty == selectedDifficulty }
        let isNewHighScore = scoresForDifficulty.isEmpty || score > (scoresForDifficulty.max()?.score ?? 0)
        
        // Add to high scores
        highScores.append(newScore)
        
        // Keep only top 10 scores per difficulty
        var filteredScores: [HighScore] = []
        for difficulty in DifficultyLevel.allCases {
            let difficultyScores = highScores.filter { $0.difficulty == difficulty }
            let topScores = difficultyScores.sorted(by: { $0.score > $1.score }).prefix(10)
            filteredScores.append(contentsOf: topScores)
        }
        
        highScores = filteredScores
        saveHighScores()
        
        // Show celebration if new high score
        if isNewHighScore {
            newHighScoreAchieved = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.newHighScoreAchieved = false
            }
        }
    }
    
    func getHighScores(for difficulty: DifficultyLevel) -> [HighScore] {
        return highScores
            .filter { $0.difficulty == difficulty }
            .sorted { $0.score > $1.score }
    }
    
    func getTopScore(for difficulty: DifficultyLevel) -> Int {
        return getHighScores(for: difficulty).first?.score ?? 0
    }
    
    func clearAllHighScores() {
        highScores = []
        saveHighScores()
    }
    
    // MARK: - Game Logic
    func selectDifficulty(_ difficulty: DifficultyLevel) {
        selectedDifficulty = difficulty
        timeRemaining = difficulty.timeLimit
        hintsRemaining = difficulty.hintCount
        setupGame()
        showDifficultySelection = false
        showHighScores = false
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
        newHighScoreAchieved = false
    }
    
    func startGame() {
        isGameActive = true
        startTimer()
        // Show all cards briefly at start
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
            addHighScore(timeLeft: timeRemaining, hintsUsed: selectedDifficulty.hintCount - hintsRemaining)
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
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.endGame()
                self.gameOver = true
                self.addHighScore(timeLeft: 0, hintsUsed: self.selectedDifficulty.hintCount - self.hintsRemaining)
            }
        }
    }
    
    func endGame() {
        isGameActive = false
        timer?.invalidate()
        timer = nil
    }
    
    func resetGame() {
        endGame()
        hintsRemaining = selectedDifficulty.hintCount
        setupGame()
        timeRemaining = selectedDifficulty.timeLimit
    }
    
    func returnToMenu() {
        endGame()
        showDifficultySelection = true
        gameOver = false
        showHighScores = false
    }
    
    func showHighScoresView() {
        showHighScores = true
        showDifficultySelection = false
        gameOver = false
    }
}
