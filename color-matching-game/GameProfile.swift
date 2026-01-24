import SwiftUI
import Combine

struct GameProfile: Identifiable, Codable {
    let id: UUID
    var name: String
    var avatar: String
    var createdAt: Date
    var lastPlayed: Date
    var totalGamesPlayed: Int
    var totalScore: Int
    var unlockedGames: [GameType]
    var unlockedLevels: [String: Int]
    
    init(name: String, avatar: String = "person.circle.fill") {
        self.id = UUID()
        self.name = name
        self.avatar = avatar
        self.createdAt = Date()
        self.lastPlayed = Date()
        self.totalGamesPlayed = 0
        self.totalScore = 0
        self.unlockedGames = [.memoryMatch, .colorMatch]
        self.unlockedLevels = [
            "memoryMatch_easy": 1,
            "memoryMatch_medium": 1,
            "memoryMatch_hard": 1,
            "colorMatch_level": 1
        ]
    }
    
    func getLevel(for game: GameType, difficulty: DifficultyLevel? = nil) -> Int {
        let key: String
        switch game {
        case .memoryMatch:
            if let difficulty = difficulty {
                key = "\(game.rawValue)_\(difficulty.rawValue.lowercased())"
            } else {
                return 1
            }
        case .colorMatch:
            key = "\(game.rawValue)_level"
        }
        return unlockedLevels[key] ?? 1
    }
}

enum GameType: String, CaseIterable, Codable {
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
        case .memoryMatch: return "Match pairs of colors in increasing difficulty"
        case .colorMatch: return "Identify correct colors with time pressure"
        }
    }
}

class ProfileManager: ObservableObject {
    @Published var profiles: [GameProfile] = []
    @Published var currentProfile: GameProfile?
    
    private let profilesKey = "gameProfiles"
    
    init() {
        loadProfiles()
        if profiles.isEmpty {
            createDefaultProfile()
        }
    }
    
    private func loadProfiles() {
        if let data = UserDefaults.standard.data(forKey: profilesKey) {
            if let decoded = try? JSONDecoder().decode([GameProfile].self, from: data) {
                profiles = decoded
            }
        }
    }
    
    private func saveProfiles() {
        if let encoded = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(encoded, forKey: profilesKey)
        }
    }
    
    private func createDefaultProfile() {
        let defaultProfile = GameProfile(name: "Player")
        profiles = [defaultProfile]
        currentProfile = defaultProfile
        saveProfiles()
    }
    
    func createProfile(name: String, avatar: String) {
        let newProfile = GameProfile(name: name, avatar: avatar)
        profiles.append(newProfile)
        currentProfile = newProfile
        saveProfiles()
    }
    
    func selectProfile(_ profile: GameProfile) {
        currentProfile = profile
    }
    
    func updateProfileScore(score: Int) {
        guard let index = profiles.firstIndex(where: { $0.id == currentProfile?.id }) else { return }
        profiles[index].totalScore += score
        profiles[index].totalGamesPlayed += 1
        profiles[index].lastPlayed = Date()
        saveProfiles()
    }
    
    func unlockLevel(for game: GameType, difficulty: DifficultyLevel? = nil, level: Int) {
        guard let index = profiles.firstIndex(where: { $0.id == currentProfile?.id }) else { return }
        
        let key: String
        switch game {
        case .memoryMatch:
            if let difficulty = difficulty {
                key = "\(game.rawValue)_\(difficulty.rawValue.lowercased())"
            } else {
                return
            }
        case .colorMatch:
            key = "\(game.rawValue)_level"
        }
        
        let currentLevel = profiles[index].unlockedLevels[key] ?? 1
        if level > currentLevel {
            profiles[index].unlockedLevels[key] = level
            saveProfiles()
        }
    }
}
