import SwiftUI

struct MemoryGameView: View {
    @StateObject private var game = MemoryGame()
    @EnvironmentObject private var profileManager: ProfileManager
    @State private var showingGameMenu = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if game.showDifficultySelection {
                    DifficultySelectionView(game: game)
                } else if game.gameOver {
                    MemoryGameOverView(game: game, profileManager: profileManager)
                } else if game.showHighScores {
                    HighScoresView(game: game)
                } else {
                    MemoryGamePlayView(game: game, profileManager: profileManager)
                }
                
                // New High Score Celebration
                if game.newHighScoreAchieved {
                    NewHighScoreCelebration()
                }
            }
            .navigationTitle("Memory Match")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingGameMenu = true
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingGameMenu) {
                MemoryGameMenuView(game: game, profileManager: profileManager)
            }
        }
    }
}

// MARK: - New High Score Celebration
struct NewHighScoreCelebration: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .scaleEffect(1.2)
                    .rotationEffect(.degrees(15))
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true),
                        value: true
                    )
                
                Text("NEW HIGH SCORE!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                    .shadow(color: .black, radius: 3)
                
                Text("🏆")
                    .font(.system(size: 60))
                    .scaleEffect(1.5)
                    .rotationEffect(.degrees(-15))
                    .animation(
                        Animation.easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true),
                        value: true
                    )
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white.opacity(0.9))
            )
            .shadow(color: .yellow.opacity(0.5), radius: 20)
        }
    }
}

// MARK: - Difficulty Selection View
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
                
                // High Score Button
                HStack {
                    Spacer()
                    
                    Button(action: {
                        game.showHighScoresView()
                    }) {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.yellow)
                            Text("High Scores")
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .padding(.trailing, 20)
                }
                
                VStack(spacing: 20) {
                    ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                        DifficultyCardView(
                            difficulty: difficulty,
                            topScore: game.getTopScore(for: difficulty),
                            action: {
                                game.selectDifficulty(difficulty)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 15) {
                    DifficultyInfoRow(
                        level: "Easy",
                        gridSize: "3×3 Grid",
                        time: "60 seconds",
                        hints: "1 hint",
                        description: "9 cards, 4 pairs, Level 1-10"
                    )
                    
                    DifficultyInfoRow(
                        level: "Medium",
                        gridSize: "4×4 Grid",
                        time: "45 seconds",
                        hints: "2 hints",
                        description: "16 cards, 8 pairs, Level 1-10"
                    )
                    
                    DifficultyInfoRow(
                        level: "Hard",
                        gridSize: "5×5 Grid",
                        time: "30 seconds",
                        hints: "3 hints",
                        description: "25 cards, 12 pairs + 1 bonus, Level 1-10"
                    )
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                Text("Match pairs of colors. Complete levels to unlock higher difficulties!")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Difficulty Card View
struct DifficultyCardView: View {
    let difficulty: DifficultyLevel
    let topScore: Int
    let action: () -> Void
    
    var backgroundColor: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    var icon: String {
        switch difficulty {
        case .easy: return "star.fill"
        case .medium: return "star.leadinghalf.filled"
        case .hard: return "star"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(difficulty.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack {
                        Label("\(difficulty.gridSize)×\(difficulty.gridSize)", systemImage: "square.grid.2x2")
                            .font(.caption)
                        
                        Spacer()
                        
                        Label("\(difficulty.timeLimit)s", systemImage: "clock")
                            .font(.caption)
                        
                        Spacer()
                        
                        Label("\(difficulty.hintCount)", systemImage: "lightbulb.fill")
                            .font(.caption)
                    }
                    .foregroundColor(.white.opacity(0.8))
                    
                    // High Score Display
                    if topScore > 0 {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            
                            Text("Best: \(topScore)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                        .padding(.top, 2)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(15)
            .shadow(color: backgroundColor.opacity(0.3), radius: 5, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Difficulty Info Row
struct DifficultyInfoRow: View {
    let level: String
    let gridSize: String
    let time: String
    let hints: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(level)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text(gridSize)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label(time, systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Label(hints, systemImage: "lightbulb.fill")
                    .font(.caption)
                    .foregroundColor(.purple)
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - High Scores View
struct HighScoresView: View {
    @ObservedObject var game: MemoryGame
    @State private var selectedDifficulty: DifficultyLevel = .easy
    
    var filteredScores: [HighScore] {
        game.getHighScores(for: selectedDifficulty)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    game.returnToMenu()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text("High Scores")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Clear Button
                if !game.highScores.isEmpty {
                    Button(action: {
                        game.clearAllHighScores()
                    }) {
                        Image(systemName: "trash")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                } else {
                    // Placeholder for alignment
                    Image(systemName: "trash")
                        .font(.title2)
                        .foregroundColor(.clear)
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // Difficulty Picker
            Picker("Difficulty", selection: $selectedDifficulty) {
                ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                    Text(difficulty.rawValue)
                        .tag(difficulty)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.vertical, 20)
            
            if filteredScores.isEmpty {
                Spacer()
                
                VStack(spacing: 20) {
                    Image(systemName: "trophy")
                        .font(.system(size: 80))
                        .foregroundColor(.gray.opacity(0.3))
                    
                    Text("No High Scores Yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text("Play a game to set your first high score!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
            } else {
                // High Scores List
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(Array(filteredScores.enumerated()), id: \.element.id) { index, score in
                            HighScoreRow(score: score, rank: index + 1)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            
            // Footer
            VStack(spacing: 15) {
                Button(action: {
                    game.returnToMenu()
                }) {
                    Text("Back to Menu")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct HighScoreRow: View {
    let score: HighScore
    let rank: Int
    
    var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .primary
        }
    }
    
    var rankIcon: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)"
        }
    }
    
    var body: some View {
        HStack {
            // Rank
            Text(rankIcon)
                .font(.title2)
                .frame(width: 40)
            
            // Score Details
            VStack(alignment: .leading, spacing: 4) {
                Text("Score: \(score.score)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(rankColor)
                
                HStack {
                    Label("\(score.moves) moves", systemImage: "arrow.right.arrow.left")
                        .font(.caption)
                    
                    Spacer()
                    
                    Label("\(score.timeLeft)s left", systemImage: "clock")
                        .font(.caption)
                    
                    Spacer()
                    
                    Label("\(score.hintsUsed) hints", systemImage: "lightbulb")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                
                Text(score.formattedDate)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Difficulty Badge
            Text(score.difficulty.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(getDifficultyColor(score.difficulty).opacity(0.2))
                .foregroundColor(getDifficultyColor(score.difficulty))
                .cornerRadius(15)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
    
    private func getDifficultyColor(_ difficulty: DifficultyLevel) -> Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}

// MARK: - Memory Game Play View (Fixed)
struct MemoryGamePlayView: View {
    @ObservedObject var game: MemoryGame
    @ObservedObject var profileManager: ProfileManager
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 10), count: game.selectedDifficulty.gridSize)
    }
    
    var topScore: Int {
        game.getTopScore(for: game.selectedDifficulty)
    }
    
    var currentLevel: Int {
        if let profile = profileManager.currentProfile {
            return profile.getLevel(for: .memoryMatch, difficulty: game.selectedDifficulty)
        }
        return 1
    }
    
    var levelProgress: Int {
        let totalRounds = 10 // 10 rounds per level
        let progress = min(game.currentRound, totalRounds)
        return Int((Double(progress) / Double(totalRounds)) * 100)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Game Header
            MemoryGameHeaderView(game: game, topScore: topScore, currentLevel: currentLevel, levelProgress: levelProgress)
            
            // Level Progress
            VStack(spacing: 10) {
                HStack {
                    Text("Level \(currentLevel)")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text("Round \(min(game.currentRound, 10))/10")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
                
                ProgressView(value: Double(min(game.currentRound, 10)), total: 10)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    .padding(.horizontal)
            }
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            
            // Game Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(game.cards) { card in
                        MemoryGameCardView(card: card) {
                            game.selectCard(card)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxHeight: .infinity)
            
            // Game Stats with Hint Button
            HStack {
                StatBox(title: "Moves", value: "\(game.moves)")
                
                // Hint Button
                MemoryHintButton(game: game)
                
                StatBox(title: "Time", value: "\(game.timeRemaining)s")
            }
            .padding(.horizontal)
            
            // Pairs Remaining
            HStack {
                StatBox(
                    title: "Pairs Left",
                    value: "\(game.selectedDifficulty.totalPairs - (game.cards.filter { $0.isMatched }.count / 2))"
                )
                
                // High Score Button
                Button(action: {
                    game.showHighScoresView()
                }) {
                    VStack {
                        Image(systemName: "trophy.fill")
                            .font(.title3)
                            .foregroundColor(.yellow)
                        Text("Top: \(topScore)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.yellow, lineWidth: 2)
                    )
                }
            }
            .padding(.horizontal)
            
            // Control Buttons
            HStack(spacing: 20) {
                MemoryControlButton(
                    title: "Reset",
                    icon: "arrow.counterclockwise",
                    color: .orange,
                    action: game.resetGame
                )
                
                MemoryControlButton(
                    title: game.isGameActive ? "Pause" : "Start",
                    icon: game.isGameActive ? "pause.fill" : "play.fill",
                    color: game.isGameActive ? .gray : .green,
                    action: {
                        if game.isGameActive {
                            game.endGame()
                        } else {
                            game.startGame()
                        }
                    }
                )
                
                MemoryControlButton(
                    title: "Menu",
                    icon: "house.fill",
                    color: .blue,
                    action: game.returnToMenu
                )
            }
            .padding(.horizontal)
            
            // Hint Active Indicator
            if game.isShowingHint {
                MemoryHintActiveIndicator()
            }
            
            // Match Feedback
            if game.showMatchFeedback {
                MemoryMatchFeedbackView(message: game.matchFeedback, color: game.matchFeedbackColor)
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

// MARK: - Memory Game Header View (Fixed)
struct MemoryGameHeaderView: View {
    @ObservedObject var game: MemoryGame
    let topScore: Int
    let currentLevel: Int
    let levelProgress: Int
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 5) {
                        Text("\(game.score)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        if game.score > topScore && topScore > 0 {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 5) {
                    Text("Difficulty")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(game.selectedDifficulty.rawValue)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(getDifficultyColor(game.selectedDifficulty))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    Text("Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(game.timeRemaining)s")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(getTimeColor(game.timeRemaining))
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            
            Text("Match pairs to complete Level \(currentLevel)")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            if game.hintsRemaining > 0 {
                Text("Tap the 💡 button for a hint!")
                    .font(.subheadline)
                    .foregroundColor(.yellow)
                    .padding(.horizontal)
            }
        }
    }
    
    private func getDifficultyColor(_ difficulty: DifficultyLevel) -> Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    private func getTimeColor(_ time: Int) -> Color {
        switch time {
        case ...10: return .red
        case 11...30: return .orange
        default: return .green
        }
    }
}

// MARK: - Memory Game Card View
struct MemoryGameCardView: View {
    let card: GameCard
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: 10)
                    .fill(card.isFaceUp ? card.color : Color(.systemGray4))
                    .frame(height: 70)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(card.isMatched ? Color.green : Color.clear, lineWidth: 3)
                    )
                
                // Card content
                if card.isFaceUp {
                    if card.isMatched {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                } else {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
            .scaleEffect(card.isFaceUp ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: card.isFaceUp)
        }
        .disabled(card.isMatched || card.isFaceUp)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Memory Hint Button
struct MemoryHintButton: View {
    @ObservedObject var game: MemoryGame
    
    var body: some View {
        Button(action: game.useHint) {
            VStack(spacing: 5) {
                Image(systemName: "lightbulb.fill")
                    .font(.title3)
                    .foregroundColor(game.hintsRemaining > 0 ? .yellow : .gray)
                
                Text("\(game.hintsRemaining)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(game.hintsRemaining > 0 ? .yellow : .gray)
                
                Text("Hints")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(game.hintsRemaining > 0 ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(game.hintsRemaining > 0 ? Color.yellow : Color.gray, lineWidth: 2)
            )
            .shadow(color: game.hintsRemaining > 0 ? Color.yellow.opacity(0.2) : Color.clear, radius: 3, x: 0, y: 2)
        }
        .disabled(game.hintsRemaining == 0 || game.isShowingHint || !game.isGameActive)
        .scaleEffect(game.hintsRemaining > 0 ? 1.0 : 0.95)
        .animation(.spring(response: 0.3), value: game.hintsRemaining)
    }
}

// MARK: - Memory Hint Active Indicator
struct MemoryHintActiveIndicator: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .font(.caption)
                .foregroundColor(.yellow)
            
            Text("Hint Active - Finding a match...")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.yellow)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: true)
    }
}

// MARK: - Stat Box (Shared Component)
struct StatBox: View {
    let title: String
    let value: String
  
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Memory Control Button
struct MemoryControlButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color)
            .cornerRadius(10)
            .shadow(color: color.opacity(0.3), radius: 3, x: 0, y: 2)
        }
    }
}

// MARK: - Memory Match Feedback View
struct MemoryMatchFeedbackView: View {
    let message: String
    let color: Color
    
    var body: some View {
        Text(message)
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(color.opacity(0.9))
            .cornerRadius(10)
            .padding(.horizontal, 40)
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: message)
    }
}

// MARK: - Memory Game Over View (Fixed)
struct MemoryGameOverView: View {
    @ObservedObject var game: MemoryGame
    @ObservedObject var profileManager: ProfileManager
    @Environment(\.dismiss) var dismiss
    
    var hintsUsed: Int {
        game.selectedDifficulty.hintCount - game.hintsRemaining
    }
    
    var isNewHighScore: Bool {
        let topScore = game.getTopScore(for: game.selectedDifficulty)
        return game.score > topScore
    }
    
    var currentLevel: Int {
        if let profile = profileManager.currentProfile {
            return profile.getLevel(for: .memoryMatch, difficulty: game.selectedDifficulty)
        }
        return 1
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 20) {
                    if isNewHighScore {
                        VStack(spacing: 10) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.yellow)
                            
                            Text("NEW HIGH SCORE!")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                    } else {
                        Image(systemName: game.timeRemaining == 0 ? "clock.badge.xmark" : "trophy.fill")
                            .font(.system(size: 80))
                            .foregroundColor(game.timeRemaining == 0 ? .red : .yellow)
                    }
                    
                    Text(game.timeRemaining == 0 ? "Time's Up!" : "Level Complete!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(game.timeRemaining == 0 ? .red : .green)
                    
                    Text(game.timeRemaining == 0 ? "Better luck next time!" : "Great Memory Skills!")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 25) {
                    MemoryGameStatRow(title: "Final Score", value: "\(game.score)", icon: "star.fill", color: .yellow)
                    
                    if isNewHighScore {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)
                                .frame(width: 40)
                            
                            Text("New High Score!")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("🏆")
                                .font(.title2)
                        }
                    }
                    
                    MemoryGameStatRow(title: "Moves", value: "\(game.moves)", icon: "arrow.right.arrow.left", color: .blue)
                    MemoryGameStatRow(title: "Hints Used", value: "\(hintsUsed)/\(game.selectedDifficulty.hintCount)", icon: "lightbulb.fill", color: .purple)
                    MemoryGameStatRow(title: "Difficulty", value: game.selectedDifficulty.rawValue, icon: "chart.bar.fill", color: getDifficultyColor(game.selectedDifficulty))
                    MemoryGameStatRow(title: "Time Left", value: "\(game.timeRemaining)s", icon: "clock.fill", color: .orange)
                    MemoryGameStatRow(title: "Current Level", value: "\(currentLevel)", icon: "chart.bar.fill", color: .green)
                    
                    // Level Progress
                    if game.currentRound >= 10 && game.timeRemaining > 0 {
                        HStack {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                                .frame(width: 40)
                            
                            Text("Level \(currentLevel + 1) Unlocked!")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Spacer()
                            
                            Text("🎯")
                                .font(.title2)
                        }
                    }
                    
                    // View High Scores Button
                    if !game.highScores.isEmpty {
                        Button(action: {
                            game.showHighScoresView()
                        }) {
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.yellow)
                                Text("View High Scores")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.yellow)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.yellow.opacity(0.1))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.yellow, lineWidth: 2)
                            )
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 15) {
                    MemoryPrimaryButton(
                        title: "Play Again",
                        icon: "arrow.clockwise",
                        color: .green,
                        action: {
                            game.resetGame()
                            game.startGame()
                            game.gameOver = false
                        }
                    )
                    
                    MemorySecondaryButton(
                        title: "Change Difficulty",
                        icon: "slider.horizontal.3",
                        color: .blue,
                        action: game.returnToMenu
                    )
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Back to Main Menu")
                            .font(.headline)
                            .foregroundColor(.purple)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical, 40)
        }
        .onAppear {
            // Update profile score
            profileManager.updateProfileScore(score: game.score)
            
            // Unlock next level if completed 10 rounds
            if game.currentRound >= 10 && game.timeRemaining > 0 {
                let nextLevel = min(currentLevel + 1, 10) // Max 10 levels per difficulty
                profileManager.unlockLevel(for: .memoryMatch, difficulty: game.selectedDifficulty, level: nextLevel)
            }
        }
    }
    
    private func getDifficultyColor(_ difficulty: DifficultyLevel) -> Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}

// MARK: - Memory Game Stat Row
struct MemoryGameStatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

// MARK: - Memory Primary Button
struct MemoryPrimaryButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.bold)
            }
            .font(.title2)
            .foregroundColor(.white)
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(15)
            .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
}

// MARK: - Memory Secondary Button
struct MemorySecondaryButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.semibold)
            }
            .font(.headline)
            .foregroundColor(color)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(color.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color, lineWidth: 2)
            )
        }
    }
}

// MARK: - Memory Game Menu View (Fixed)
struct MemoryGameMenuView: View {
    @ObservedObject var game: MemoryGame
    @ObservedObject var profileManager: ProfileManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let profile = profileManager.currentProfile {
                    VStack(spacing: 10) {
                        Image(systemName: profile.avatar)
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text(profile.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Level \(profile.getLevel(for: .memoryMatch, difficulty: game.selectedDifficulty)) - \(game.selectedDifficulty.rawValue)")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    .padding()
                }
                
                Divider()
                
                VStack(spacing: 15) {
                    MemoryMenuButton(title: "Restart Game", icon: "arrow.counterclockwise", color: .orange) {
                        game.resetGame()
                        dismiss()
                    }
                    
                    MemoryMenuButton(title: game.isGameActive ? "Pause Game" : "Resume Game",
                              icon: game.isGameActive ? "pause.fill" : "play.fill",
                              color: .green) {
                        if game.isGameActive {
                            game.endGame()
                        } else {
                            game.startGame()
                        }
                        dismiss()
                    }
                    
                    MemoryMenuButton(title: "High Scores", icon: "trophy.fill", color: .yellow) {
                        game.showHighScoresView()
                        dismiss()
                    }
                    
                    MemoryMenuButton(title: "Change Difficulty", icon: "slider.horizontal.3", color: .blue) {
                        game.returnToMenu()
                        dismiss()
                    }
                }
                .padding()
                
                Spacer()
                
                Button("Close Menu") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.bottom, 30)
            }
            .navigationTitle("Game Menu")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Memory Menu Button
struct MemoryMenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}
