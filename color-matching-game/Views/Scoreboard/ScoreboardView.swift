import SwiftUI

struct ScoreboardView: View {
    @ObservedObject var scoreManager: ScoreManager
    @State private var selectedDifficulty: DifficultyLevel = .easy
    @Environment(\.presentationMode) var presentationMode
    
    var filteredScores: [GameScore] {
        scoreManager.getScores(forDifficulty: selectedDifficulty.rawValue)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 15) {
                    HStack {
                        Text("🏆 High Scores")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Difficulty Picker
                    Picker("Difficulty", selection: $selectedDifficulty) {
                        ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                            Text(difficulty.rawValue).tag(difficulty)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // High Score Display
                    HStack {
                        VStack(alignment: .leading) {
                            Text("High Score")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(scoreManager.getHighScore(forDifficulty: selectedDifficulty.rawValue))")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Total Games")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(filteredScores.count)")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                // Scores List
                if filteredScores.isEmpty {
                    EmptyScoresView()
                } else {
                    ScoresListView(scores: filteredScores)
                }
                
                // Clear Button
                ClearScoresButton(scoreManager: scoreManager, selectedDifficulty: selectedDifficulty)
            }
            .navigationBarHidden(true)
        }
    }
}

struct ScoresListView: View {
    let scores: [GameScore]
    
    var body: some View {
        List {
            ForEach(Array(scores.enumerated()), id: \.element.id) { index, score in
                ScoreRow(score: score, rank: index + 1)
                    .listRowBackground(index == 0 ? Color.yellow.opacity(0.1) : Color.clear)
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct ScoreRow: View {
    let score: GameScore
    let rank: Int
    
    var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .primary
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Rank
            Text("\(rank)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(rankColor)
                .frame(width: 40, alignment: .center)
            
            // Player Info
            VStack(alignment: .leading, spacing: 4) {
                Text(score.playerName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(score.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Score Display - FIXED THIS PART
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(score.score)")  // This should show the score
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                
                HStack(spacing: 10) {
                    Label("\(score.timeTaken)s", systemImage: "clock")
                        .font(.caption2)
                    
                    Label("\(score.hintsUsed)", systemImage: "lightbulb")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
            .frame(minWidth: 100, alignment: .trailing) // Ensure enough width
        }
        .padding(.vertical, 8)
        .onAppear {
            print("ScoreRow displaying: \(score.playerName) - \(score.score)") // Debug
        }
    }
}

struct EmptyScoresView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "trophy")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Scores Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text("Play a game to see your scores here!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

struct ClearScoresButton: View {
    @ObservedObject var scoreManager: ScoreManager
    let selectedDifficulty: DifficultyLevel
    @State private var showClearAlert = false
    
    var body: some View {
        VStack {
            Divider()
            
            Button(action: {
                showClearAlert = true
            }) {
                HStack {
                    Image(systemName: "trash")
                        .font(.body)
                    Text("Clear \(selectedDifficulty.rawValue) Scores")
                        .fontWeight(.medium)
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
            }
            .alert(isPresented: $showClearAlert) {
                Alert(
                    title: Text("Clear Scores"),
                    message: Text("Are you sure you want to clear all \(selectedDifficulty.rawValue) scores? This cannot be undone."),
                    primaryButton: .destructive(Text("Clear")) {
                        scoreManager.clearScores(forDifficulty: selectedDifficulty.rawValue)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}
