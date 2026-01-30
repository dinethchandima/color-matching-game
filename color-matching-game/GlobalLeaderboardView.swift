import SwiftUI

struct GlobalLeaderboardView: View {
    @ObservedObject var firebaseManager = FirebaseManager.shared
    @ObservedObject var profileManager: ProfileManager
    @State private var selectedGame: GameType = .memoryMatch
    @State private var selectedDifficulty: DifficultyLevel = .easy
    @State private var showingFilters = false
    @State private var timeFilter: TimeFilter = .allTime
    
    enum TimeFilter: String, CaseIterable {
        case allTime = "All Time"
        case today = "Today"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        
        var dateRange: (start: Date?, end: Date?) {
            let calendar = Calendar.current
            let now = Date()
            
            switch self {
            case .allTime:
                return (nil, nil)
            case .today:
                let start = calendar.startOfDay(for: now)
                return (start, now)
            case .thisWeek:
                let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
                return (start, now)
            case .thisMonth:
                let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
                return (start, now)
            }
        }
    }
    
    var filteredScores: [GlobalScore] {
        var scores = firebaseManager.globalScores
        
        // Filter by game type
        scores = scores.filter { $0.gameType == selectedGame.rawValue }
        
        // Filter by difficulty
        if selectedGame == .memoryMatch {
            scores = scores.filter { $0.difficulty == selectedDifficulty.rawValue }
        }
        
        // Filter by time range
        let (startDate, endDate) = timeFilter.dateRange
        if let startDate = startDate {
            scores = scores.filter { $0.timestamp >= startDate }
        }
        if let endDate = endDate {
            scores = scores.filter { $0.timestamp <= endDate }
        }
        
        // Sort by score
        return scores.sorted { $0.score > $1.score }
    }
    
    var userRank: Int {
        guard let profile = profileManager.currentProfile else { return 0 }
        return filteredScores.firstIndex(where: { $0.profileId == profile.id.uuidString }) ?? 0 + 1
    }
    
    var userScore: GlobalScore? {
        guard let profile = profileManager.currentProfile else { return nil }
        return filteredScores.first(where: { $0.profileId == profile.id.uuidString })
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HeaderView
            
            // Filters
            FilterView
            
            // Connectivity Status
            ConnectivityView
            
            if firebaseManager.globalScores.isEmpty && firebaseManager.isSignedIn {
                LoadingView
            } else if filteredScores.isEmpty {
                EmptyStateView
            } else {
                LeaderboardListView
            }
        }
        .navigationTitle("Global Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            refreshLeaderboard()
        }
        .sheet(isPresented: $showingFilters) {
            FilterSettingsView(
                selectedGame: $selectedGame,
                selectedDifficulty: $selectedDifficulty,
                timeFilter: $timeFilter
            )
        }
    }
    
    private var HeaderView: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Global Leaderboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Compete with players worldwide")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showingFilters = true
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // User Rank Display
            if let userScore = userScore, userRank > 0 {
                UserRankCard(rank: userRank, score: userScore)
            }
        }
        .padding(.vertical)
        .background(Color.blue.opacity(0.1))
    }
    
    private var FilterView: some View {
        HStack {
            Menu {
                ForEach(GameType.allCases, id: \.self) { game in
                    Button(game.rawValue) {
                        selectedGame = game
                        refreshLeaderboard()
                    }
                }
            } label: {
                FilterChip(
                    title: selectedGame.rawValue,
                    icon: selectedGame.icon
                )
            }
            
            if selectedGame == .memoryMatch {
                Menu {
                    ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                        Button(difficulty.rawValue) {
                            selectedDifficulty = difficulty
                            refreshLeaderboard()
                        }
                    }
                } label: {
                    FilterChip(
                        title: selectedDifficulty.rawValue,
                        icon: "chart.bar.fill"
                    )
                }
            }
            
            Menu {
                ForEach(TimeFilter.allCases, id: \.self) { filter in
                    Button(filter.rawValue) {
                        timeFilter = filter
                    }
                }
            } label: {
                FilterChip(
                    title: timeFilter.rawValue,
                    icon: "clock.fill"
                )
            }
            
            Spacer()
            
            Button(action: refreshLeaderboard) {
                Image(systemName: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
    
    private var ConnectivityView: some View {
        Group {
            if !firebaseManager.isSignedIn {
                HStack {
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.red)
                    Text("Offline - Showing cached scores")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
            }
            
            if let error = firebaseManager.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
    }
    
    private var LoadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading global scores...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var EmptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("No Scores Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text("Be the first to submit a score!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var LeaderboardListView: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(Array(filteredScores.enumerated()), id: \.element.id) { index, score in
                    LeaderboardRow(
                        score: score,
                        rank: index + 1,
                        isCurrentUser: score.profileId == profileManager.currentProfile?.id.uuidString
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
    
    private func refreshLeaderboard() {
        let difficulty = selectedGame == .memoryMatch ? selectedDifficulty.rawValue : nil
        firebaseManager.fetchGlobalScores(
            gameType: selectedGame.rawValue,
            difficulty: difficulty
        )
    }

}

struct UserRankCard: View {
    let rank: Int
    let score: GlobalScore
    
    var body: some View {
        HStack {
            RankBadge(rank: rank)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Rank")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("#\(rank)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("\(score.score) points")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Level")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(score.level)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            Image(systemName: "chevron.down")
                .font(.caption2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .cornerRadius(15)
    }
}

struct LeaderboardRow: View {
    let score: GlobalScore
    let rank: Int
    let isCurrentUser: Bool
    
    var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
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
            
            // Avatar
            Image(systemName: score.avatar)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            // Player Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(score.profileName)
                        .font(.headline)
                        .fontWeight(isCurrentUser ? .bold : .medium)
                        .foregroundColor(isCurrentUser ? .blue : .primary)
                    
                    if isCurrentUser {
                        Image(systemName: "person.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                HStack {
                    Image(systemName: "flag.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(score.countryCode)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(score.formattedDate)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Score
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(score.score)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(rankColor)
                
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                    
                    Text("Lvl \(score.level)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(isCurrentUser ? Color.blue.opacity(0.1) : Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrentUser ? Color.blue : Color.clear, lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

struct RankBadge: View {
    let rank: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(rankColor)
                .frame(width: 50, height: 50)
            
            Text("\(rank)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }
}

struct FilterSettingsView: View {
    @Binding var selectedGame: GameType
    @Binding var selectedDifficulty: DifficultyLevel
    @Binding var timeFilter: GlobalLeaderboardView.TimeFilter
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Game Type")) {
                    Picker("Select Game", selection: $selectedGame) {
                        ForEach(GameType.allCases, id: \.self) { game in
                            Label(game.rawValue, systemImage: game.icon)
                                .tag(game)
                        }
                    }
                    .pickerStyle(InlinePickerStyle())
                }
                
                if selectedGame == .memoryMatch {
                    Section(header: Text("Difficulty")) {
                        Picker("Select Difficulty", selection: $selectedDifficulty) {
                            ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                                Text(difficulty.rawValue)
                                    .tag(difficulty)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                Section(header: Text("Time Range")) {
                    Picker("Select Time Range", selection: $timeFilter) {
                        ForEach(GlobalLeaderboardView.TimeFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue)
                                .tag(filter)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("Filter Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
