import SwiftUI
import Foundation
import Combine


struct ColorItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let color: Color
    let correctName: String
    
    static func == (lhs: ColorItem, rhs: ColorItem) -> Bool {
        lhs.id == rhs.id
    }
}

class ColorMatchGame: ObservableObject {
    // MARK: - Published Properties
    @Published var score: Int = 0
    @Published var timeRemaining: Int = 60
    @Published var isGameActive: Bool = false
    @Published var currentRound: Int = 1
    @Published var selectedColorItem: ColorItem? = nil
    @Published var showFeedback: Bool = false
    @Published var feedbackMessage: String = ""
    @Published var feedbackColor: Color = .clear
    @Published var currentColors: [ColorItem] = []
    @Published var shuffledNames: [String] = []
    
    // MARK: - Private Properties
    private var timer: Timer?
    private let totalRounds = 10
    
    private let allColors: [ColorItem] = [
        ColorItem(name: "Red", color: .red, correctName: "Red"),
        ColorItem(name: "Blue", color: .blue, correctName: "Blue"),
        ColorItem(name: "Green", color: .green, correctName: "Green"),
        ColorItem(name: "Yellow", color: .yellow, correctName: "Yellow"),
        ColorItem(name: "Purple", color: .purple, correctName: "Purple"),
        ColorItem(name: "Orange", color: .orange, correctName: "Orange"),
        ColorItem(name: "Pink", color: .pink, correctName: "Pink"),
        ColorItem(name: "Brown", color: .brown, correctName: "Brown"),
        ColorItem(name: "Gray", color: .gray, correctName: "Gray"),
        ColorItem(name: "Cyan", color: .cyan, correctName: "Cyan"),
        ColorItem(name: "Mint", color: .mint, correctName: "Mint"),
        ColorItem(name: "Teal", color: .teal, correctName: "Teal")
    ]
    
    // MARK: - Initializer
    init() {
        setupNewRound()
    }
    
    // MARK: - Game Logic
    func startGame() {
        score = 0
        currentRound = 1
        timeRemaining = 60
        isGameActive = true
        setupNewRound()
        startTimer()
    }
    
    private func setupNewRound() {
        // Clear selection
        selectedColorItem = nil
        
        // Shuffle and pick 4 colors
        let shuffled = allColors.shuffled()
        let selected = Array(shuffled.prefix(4))
        
        // Create game items with possibly incorrect names
        var gameColors: [ColorItem] = []
        for color in selected {
            let shouldShowCorrectName = Bool.random()
            let displayName: String
            
            if shouldShowCorrectName {
                displayName = color.name
            } else {
                // Get a wrong name from a different color
                let wrongColors = allColors.filter { $0.id != color.id }
                if let wrongColor = wrongColors.randomElement() {
                    displayName = wrongColor.name
                } else {
                    displayName = color.name
                }
            }
            
            gameColors.append(ColorItem(
                name: displayName,
                color: color.color,
                correctName: color.name
            ))
        }
        
        currentColors = gameColors
        shuffledNames = gameColors.map { $0.name }.shuffled()
    }
    
    func selectColorItem(_ item: ColorItem) {
        selectedColorItem = item
    }
    
    func checkAnswer(selectedName: String) {
        guard let selectedColor = selectedColorItem else { return }
        
        let isCorrect = selectedColor.name == selectedName &&
                       selectedColor.name == selectedColor.correctName
        
        if isCorrect {
            score += 10
            showFeedback(message: "Correct! +10 points", color: .green)
        } else {
            score = max(0, score - 5)
            showFeedback(message: "Wrong! -5 points", color: .red)
        }
        
        // Move to next round after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            if self.currentRound < self.totalRounds {
                self.currentRound += 1
                self.setupNewRound()
            } else {
                self.endGame()
            }
        }
    }
    
    private func showFeedback(message: String, color: Color) {
        feedbackMessage = message
        feedbackColor = color
        showFeedback = true
        
        // Hide feedback after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.showFeedback = false
        }
    }
    
    private func startTimer() {
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
        timer?.invalidate()
        timer = nil
    }
    
    func resetGame() {
        endGame()
        score = 0
        currentRound = 1
        timeRemaining = 60
        setupNewRound()
    }
}
