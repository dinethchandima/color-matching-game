import SwiftUI

struct ColorMatchLevelView: View {
    @StateObject private var game = ColorMatchGame()
    @EnvironmentObject private var profileManager: ProfileManager
    @State private var showingGameMenu = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if game.showLevelComplete {
                    ColorLevelCompleteView(game: game)
                } else if game.gameOver {
                    ColorGameOverView(game: game, profileManager: profileManager)
                } else {
                    ColorGamePlayView(game: game)
                }
            }
            .navigationTitle("Color Match")
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
                ColorGameMenuView(game: game, profileManager: profileManager)
            }
        }
    }
}

// MARK: - Color Game Play View (Renamed from GamePlayView)
struct ColorGamePlayView: View {
    @ObservedObject var game: ColorMatchGame
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 15), count: game.currentLevelData.gridSize)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Game Header
            ColorGameHeaderView(game: game)
            
            // Target Color Display
            VStack(spacing: 15) {
                Text("Find this color:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                if let correctColor = game.correctColor {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(correctColor)
                        .frame(height: 100)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.blue, lineWidth: 3)
                        )
                        .padding(.horizontal, 40)
                    
                    Text(getColorName(correctColor))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
            
            // Color Options Grid
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(game.currentColors) { colorOption in
                    ColorOptionView(colorOption: colorOption) {
                        game.selectColor(colorOption)
                    }
                }
            }
            .padding(.horizontal)
            
            // Level Progress
            VStack(spacing: 10) {
                ProgressView(value: Double(game.score), total: Double(game.currentLevelData.requiredScore))
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
                
                HStack {
                    Text("Level \(game.currentLevel)")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text("\(game.score)/\(game.currentLevelData.requiredScore)")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            
            Spacer()
            
            // Game Status
            VStack(spacing: 10) {
                if !game.isGameActive && !game.gameOver && !game.showLevelComplete {
                    Button(action: {
                        game.startGame()
                    }) {
                        Text("Start Game")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(height: 60)
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                }
                
                Text("Level \(game.currentLevel): \(game.currentLevelData.description)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Feedback
            if game.showFeedback {
                ColorFeedbackView(message: game.feedbackMessage, color: game.feedbackColor)
            }
        }
        .padding(.vertical)
        .onAppear {
            if !game.isGameActive && !game.gameOver {
                game.startGame()
            }
        }
    }
    
    private func getColorName(_ color: Color) -> String {
        if let index = game.allColors.firstIndex(of: color) {
            return game.colorNames[min(index, game.colorNames.count - 1)]
        }
        return "Color"
    }
}

// MARK: - Color Game Header View (Renamed from GameHeaderView)
struct ColorGameHeaderView: View {
    @ObservedObject var game: ColorMatchGame
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Score")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(game.score)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            VStack(alignment: .center, spacing: 5) {
                Text("Level")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(game.currentLevel)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
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
    }
    
    private func getTimeColor(_ time: Int) -> Color {
        switch time {
        case ...10: return .red
        case 11...30: return .orange
        default: return .green
        }
    }
}

struct ColorOptionView: View {
    let colorOption: ColorOption
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorOption.color)
                    .frame(height: 70)
                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ColorLevelCompleteView: View {
    @ObservedObject var game: ColorMatchGame
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                
                Text("Level \(game.currentLevel) Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("Score: \(game.score)")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                if game.currentLevel < game.levels.count {
                    Text("Next Level: \(game.levels[game.currentLevel].description)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                } else {
                    Text("All Levels Completed!")
                        .font(.headline)
                        .foregroundColor(.yellow)
                }
            }
            
            Spacer()
            
            if game.currentLevel < game.levels.count {
                Button(action: {
                    // Only call nextLevel when button is pressed
                    game.nextLevel()
                }) {
                    Text("Continue to Level \(game.currentLevel + 1)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.2), radius: 20)
        .padding(40)
    }
}

struct ColorGameOverView: View {
    @ObservedObject var game: ColorMatchGame
    @ObservedObject var profileManager: ProfileManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "flag.checkered")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Game Over")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                VStack(spacing: 15) {
                    ColorGameStatRow(title: "Final Score", value: "\(game.score)", icon: "star.fill", color: .yellow)
                    ColorGameStatRow(title: "Level Reached", value: "\(game.currentLevel)", icon: "chart.bar.fill", color: .green)
                    ColorGameStatRow(title: "Total Time", value: "\(game.currentLevelData.timeLimit - game.timeRemaining)s", icon: "clock.fill", color: .orange)
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Button(action: {
                    game.restartGame()
                }) {
                    Text("Play Again")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(15)
                }
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Back to Menu")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
        .onAppear {
            // Update profile score
            profileManager.updateProfileScore(score: game.score)
            
            // Unlock next level if applicable
            let nextLevel = min(game.currentLevel + 1, game.levels.count)
            profileManager.unlockLevel(for: .colorMatch, level: nextLevel)
        }
    }
}

struct ColorGameStatRow: View {
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

struct ColorGameMenuView: View {
    @ObservedObject var game: ColorMatchGame
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
                        
                        // ✅ Use ProfileManager to get level
                        let level = profileManager.getLevel(for: .colorMatch)
                        Text("Level \(level)")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    .padding()
                }

                
                Divider()
                
                VStack(spacing: 15) {
                    ColorMenuButton(title: "Restart Level", icon: "arrow.counterclockwise", color: .orange) {
                        game.restartLevel()
                        dismiss()
                    }
                    
                    ColorMenuButton(title: "New Game", icon: "play.fill", color: .green) {
                        game.restartGame()
                        dismiss()
                    }
                    
                    ColorMenuButton(title: "Level Selection", icon: "list.number", color: .blue) {
                        // Future: Add level selection
                        dismiss()
                    }
                }
                .padding()
                
                Spacer()
                
                Button("Close") {
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

struct ColorMenuButton: View {
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

struct ColorFeedbackView: View {
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
