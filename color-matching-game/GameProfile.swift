import SwiftUI
import FirebaseAuth
import Combine

struct GameProfile: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var avatar: String
    var createdAt: Date
    var lastPlayed: Date
    var totalGamesPlayed: Int
    var totalScore: Int
    var unlockedGames: [GameType]
    var unlockedLevels: [String: Int]
    var privacyAccepted: Bool
    var firebaseUserId: String?
    
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
        self.privacyAccepted = false
        self.firebaseUserId = nil
    }
    
    static func == (lhs: GameProfile, rhs: GameProfile) -> Bool {
        lhs.id == rhs.id
    }
    
    enum GameType: String, Codable {
        case memoryMatch
        case colorMatch
    }

    enum DifficultyLevel: String, Codable {
        case easy
        case medium
        case hard
    }

}


class ProfileManager: ObservableObject {
    @Published var profiles: [GameProfile] = []
    @Published var currentProfile: GameProfile?
    @Published var showPrivacyPolicy = false
    @Published var isLoading = false
    
    private let profilesKey = "gameProfiles"
    private let privacyAcceptedKey = "privacyAccepted"
    private let firebaseManager = FirebaseManager.shared
    
    init() {
        loadProfiles()
        checkPrivacyPolicy()
    }
    
    private func loadProfiles() {
        if let data = UserDefaults.standard.data(forKey: profilesKey) {
            if let decoded = try? JSONDecoder().decode([GameProfile].self, from: data) {
                profiles = decoded
                // Try to load last used profile
                if let lastProfileId = UserDefaults.standard.string(forKey: "lastProfileId"),
                   let profile = profiles.first(where: { $0.id.uuidString == lastProfileId }) {
                    currentProfile = profile
                } else {
                    currentProfile = profiles.first
                }
            }
        }
        
        // If no profiles exist, create a default one
        if profiles.isEmpty {
            createProfile(name: "Player", avatar: "person.circle.fill")
        }
    }
    
    private func saveProfiles() {
        if let encoded = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(encoded, forKey: profilesKey)
        }
    }
    
    private func checkPrivacyPolicy() {
        let hasAccepted = UserDefaults.standard.bool(forKey: privacyAcceptedKey)
        if !hasAccepted && currentProfile != nil {
            showPrivacyPolicy = true
        }
    }
    
    func acceptPrivacyPolicy() {
        UserDefaults.standard.set(true, forKey: privacyAcceptedKey)
        if let index = profiles.firstIndex(where: { $0.id == currentProfile?.id }) {
            profiles[index].privacyAccepted = true
            saveProfiles()
        }
        showPrivacyPolicy = false
        
        // Initialize Firebase connection
        initializeFirebase()
    }
    
    private func initializeFirebase() {
        isLoading = true
       /* firebaseManager.signInAnonymously { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let userId):
                    // Update profile with Firebase user ID
                    if let index = self.profiles.firstIndex(where: { $0.id == self.currentProfile?.id }) {
                        self.profiles[index].firebaseUserId = userId
                        self.saveProfiles()
                    }
                case .failure(let error):
                    print("Firebase initialization failed: \(error)")
                }
            }
        }*/
    }
    
    func createProfile(name: String, avatar: String) {
        var newProfile = GameProfile(name: name, avatar: avatar)
        
        // Initialize Firebase for new profile
        /*firebaseManager.signInAnonymously { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userId):
                    newProfile.firebaseUserId = userId
                case .failure(let error):
                    print("Failed to create Firebase user: \(error)")
                }
                
                self.profiles.append(newProfile)
                self.currentProfile = newProfile
                self.saveProfiles()
                self.showPrivacyPolicy = true
            }
        }*/
    }
    
    func selectProfile(_ profile: GameProfile) {
        currentProfile = profile
        UserDefaults.standard.set(profile.id.uuidString, forKey: "lastProfileId")
        
        // Check if privacy policy needs to be shown
        if !profile.privacyAccepted {
            showPrivacyPolicy = true
        } else {
            // Initialize Firebase for selected profile
            if profile.firebaseUserId == nil {
                initializeFirebase()
            }
        }
    }
    
    func updateProfileScore(score: Int) {
        guard let index = profiles.firstIndex(where: { $0.id == currentProfile?.id }) else { return }
        
        profiles[index].totalScore += score
        profiles[index].totalGamesPlayed += 1
        profiles[index].lastPlayed = Date()
        saveProfiles()
        
        // Submit to global leaderboard if connected
        submitToLeaderboard(score: score)
    }
    
    private func submitToLeaderboard(score: Int) {
        guard let profile = currentProfile,
              profile.privacyAccepted,
              firebaseManager.isSignedIn else { return }
        
        // You can add more context about the game here
        // For now, we'll submit a generic score
        firebaseManager.submitScore(
            profileId: profile.id.uuidString,
            profileName: profile.name,
            avatar: profile.avatar,
            score: score,
            gameType: "total",
            difficulty: "all",
            level: 1
        )
    }
    
    func submitGameScore(score: Int, gameType: GameType, difficulty: DifficultyLevel? = nil, level: Int = 1) {
        guard let profile = currentProfile,
              profile.privacyAccepted,
              firebaseManager.isSignedIn else { return }
        
        firebaseManager.submitScore(
            profileId: profile.id.uuidString,
            profileName: profile.name,
            avatar: profile.avatar,
            score: score,
            gameType: gameType.rawValue,
            difficulty: difficulty?.rawValue ?? "none",
            level: level
        )
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
    
    func getLevel(for game: GameType, difficulty: DifficultyLevel? = nil) -> Int {
        guard let profile = currentProfile else { return 1 }
        
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
        return profile.unlockedLevels[key] ?? 1
    }
    
    func deleteProfile(_ profile: GameProfile) {
        profiles.removeAll { $0.id == profile.id }
        
        if currentProfile?.id == profile.id {
            currentProfile = profiles.first
        }
        
        saveProfiles()
    }
    
    func updateProfileName(_ name: String) {
        guard let index = profiles.firstIndex(where: { $0.id == currentProfile?.id }) else { return }
        
        profiles[index].name = name
        saveProfiles()
    }
    
    func updateProfileAvatar(_ avatar: String) {
        guard let index = profiles.firstIndex(where: { $0.id == currentProfile?.id }) else { return }
        
        profiles[index].avatar = avatar
        saveProfiles()
    }
}
