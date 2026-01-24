import SwiftUI
import Foundation
import Combine

// MARK: - Color Matching Game Models
struct ColorOption: Identifiable {
    let id = UUID()
    let color: Color
    let name: String
    let isCorrect: Bool
}

struct ColorMatchLevel {
    let level: Int
    let colors: [Color]
    let timeLimit: Int
    let requiredScore: Int
    let gridSize: Int
    let description: String
}

class ColorMatchGame: ObservableObject {
    @Published var currentLevel = 1
    @Published var score = 0
    @Published var timeRemaining = 60
    @Published var isGameActive = false
    @Published var gameOver = false
    @Published var showLevelComplete = false
    @Published var currentColors: [ColorOption] = []
    @Published var correctColor: Color?
    @Published var feedbackMessage = ""
    @Published var showFeedback = false
    @Published var feedbackColor: Color = .clear
    
    private var timer: Timer?
    private var levelTimer: Timer?
    
    let allColors: [Color] = [
        .red, .blue, .green, .yellow, .orange, .purple,
        .pink, .brown, .cyan, .mint, .teal, .indigo,
        .gray, .black, .white.opacity(0.9), .red.opacity(0.7),
        .blue.opacity(0.7), .green.opacity(0.7), .yellow.opacity(0.7)
    ]
    
    let colorNames = [
        "Red", "Blue", "Green", "Yellow", "Orange", "Purple",
        "Pink", "Brown", "Cyan", "Mint", "Teal", "Indigo",
        "Gray", "Black", "White", "Light Red", "Light Blue",
        "Light Green", "Light Yellow"
    ]
    
    var levels: [ColorMatchLevel] {
        [
            ColorMatchLevel(
                level: 1,
                colors: Array(allColors.prefix(5)),
                timeLimit: 60,
                requiredScore: 100,
                gridSize: 2,
                description: "Basic Colors"
            ),
            ColorMatchLevel(
                level: 2,
                colors: Array(allColors.prefix(8)),
                timeLimit: 50,
                requiredScore: 150,
                gridSize: 2,
                description: "More Colors"
            ),
            ColorMatchLevel(
                level: 3,
                colors: Array(allColors.prefix(12)),
                timeLimit: 45,
                requiredScore: 200,
                gridSize: 3,
                description: "Advanced Colors"
            ),
            ColorMatchLevel(
                level: 4,
                colors: Array(allColors.prefix(15)),
                timeLimit: 40,
                requiredScore: 250,
                gridSize: 3,
                description: "Expert Colors"
            ),
            ColorMatchLevel(
                level: 5,
                colors: allColors,
                timeLimit: 35,
                requiredScore: 300,
                gridSize: 4,
                description: "Master Colors"
            ),
            ColorMatchLevel(
                level: 6,
                colors: allColors,
                timeLimit: 30,
                requiredScore: 350,
                gridSize: 4,
                description: "Speed Challenge"
            ),
            ColorMatchLevel(
                level: 7,
                colors: allColors,
                timeLimit: 25,
                requiredScore: 400,
                gridSize: 4,
                description: "Color Expert"
            ),
            ColorMatchLevel(
                level: 8,
                colors: allColors,
                timeLimit: 20,
                requiredScore: 450,
                gridSize: 5,
                description: "Ultimate Challenge"
            ),
            ColorMatchLevel(
                level: 9,
                colors: allColors,
                timeLimit: 15,
                requiredScore: 500,
                gridSize: 5,
                description: "Impossible Mode"
            ),
            ColorMatchLevel(
                level: 10,
                colors: allColors,
                timeLimit: 10,
                requiredScore: 600,
                gridSize: 5,
                description: "Color Master"
            )
        ]
    }
    
    var currentLevelData: ColorMatchLevel {
        let index = min(currentLevel - 1, levels.count - 1)
        return levels[index]
    }
    
    init() {
        setupLevel()
    }
    
    func startGame() {
        isGameActive = true
        gameOver = false
        startTimer()
    }
    
    func setupLevel() {
        let levelData = currentLevelData
        
        // Select a random correct color
        let correctColorIndex = Int.random(in: 0..<levelData.colors.count)
        correctColor = levelData.colors[correctColorIndex]
        
        // Get color name
        let correctColorName = colorNames[min(correctColorIndex, colorNames.count - 1)]
        
        // Generate color options
        var options: [ColorOption] = []
        
        // Add correct option
        options.append(ColorOption(
            color: levelData.colors[correctColorIndex],
            name: correctColorName,
            isCorrect: true
        ))
        
        // Add incorrect options
        let availableColors = levelData.colors.filter { $0 != correctColor }
        let numberOfOptions = (levelData.gridSize * levelData.gridSize) - 1
        let randomColors = availableColors.shuffled().prefix(numberOfOptions)
        
        for color in randomColors {
            let colorIndex = allColors.firstIndex(of: color) ?? 0
            let colorName = colorNames[min(colorIndex, colorNames.count - 1)]
            options.append(ColorOption(
                color: color,
                name: colorName,
                isCorrect: false
            ))
        }
        
        currentColors = options.shuffled()
        timeRemaining = levelData.timeLimit
    }
    
    func selectColor(_ colorOption: ColorOption) {
        guard isGameActive else { return }
        
        if colorOption.isCorrect {
            // Correct selection
            score += 10
            feedbackMessage = "Correct! +10 points"
            feedbackColor = .green
            
            // Check if level completed
            if score >= currentLevelData.requiredScore {
                completeLevel()
            } else {
                // Continue with same level
                setupLevel()
            }
        } else {
            // Incorrect selection
            score = max(0, score - 5)
            feedbackMessage = "Wrong! -5 points"
            feedbackColor = .red
        }
        
        showFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showFeedback = false
        }
    }
    
    func completeLevel() {
        isGameActive = false
        showLevelComplete = true
        timer?.invalidate()
        
        // Check if there are more levels
        if currentLevel < levels.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.nextLevel()
            }
        } else {
            // Game completed
            gameOver = true
        }
    }
    
    func nextLevel() {
        currentLevel += 1
        showLevelComplete = false
        setupLevel()
        isGameActive = true
        startTimer()
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.endGame()
            }
        }
    }
    
    func endGame() {
        isGameActive = false
        gameOver = true
        timer?.invalidate()
    }
    
    func restartGame() {
        currentLevel = 1
        score = 0
        gameOver = false
        showLevelComplete = false
        setupLevel()
    }
    
    func restartLevel() {
        score = 0
        gameOver = false
        showLevelComplete = false
        setupLevel()
        isGameActive = true
        startTimer()
    }
}
