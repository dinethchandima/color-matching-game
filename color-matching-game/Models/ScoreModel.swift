import Foundation
import Combine

struct GameScore: Identifiable, Codable {
    let id = UUID()
    let playerName: String
    let score: Int
    let difficulty: String
    let date: Date
    let timeTaken: Int
    let hintsUsed: Int
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

class ScoreManager: ObservableObject {
    @Published var scores: [GameScore] = []
    private let scoresKey = "memoryGameScores"
    
    init() {
        loadScores()
        print("ScoreManager initialized. Total scores: \(scores.count)")
        for score in scores {
            print("Score: \(score.playerName) - \(score.score) - \(score.difficulty)")
        }
    }
    
    func addScore(_ score: GameScore) {
        scores.append(score)
        scores.sort { $0.score > $1.score }
        saveScores()
        print("Score added: \(score.playerName) - \(score.score) - \(score.difficulty)")
        print("Total scores now: \(scores.count)")
    }
    
    func getScores(forDifficulty difficulty: String) -> [GameScore] {
        let filtered = scores.filter { $0.difficulty == difficulty }
        print("Getting scores for \(difficulty): \(filtered.count) found")
        return filtered
    }
    
    func getHighScore(forDifficulty difficulty: String) -> Int {
        let difficultyScores = getScores(forDifficulty: difficulty)
        let highScore = difficultyScores.first?.score ?? 0
        print("High score for \(difficulty): \(highScore)")
        return highScore
    }
    
    func clearAllScores() {
        scores.removeAll()
        saveScores()
    }
    
    func clearScores(forDifficulty difficulty: String) {
        scores.removeAll { $0.difficulty == difficulty }
        saveScores()
    }
    
    private func saveScores() {
        do {
            let encoded = try JSONEncoder().encode(scores)
            UserDefaults.standard.set(encoded, forKey: scoresKey)
            print("Scores saved successfully")
        } catch {
            print("Error saving scores: \(error)")
        }
    }
    
    private func loadScores() {
        if let data = UserDefaults.standard.data(forKey: scoresKey) {
            do {
                let decoded = try JSONDecoder().decode([GameScore].self, from: data)
                scores = decoded.sorted { $0.score > $1.score }
                print("Scores loaded: \(scores.count)")
            } catch {
                print("Error loading scores: \(error)")
                scores = []
            }
        } else {
            print("No saved scores found")
            scores = []
        }
    }
}
