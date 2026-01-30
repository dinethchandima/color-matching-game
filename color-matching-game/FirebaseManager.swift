import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import Combine

struct GlobalScore: Identifiable, Codable {
    @DocumentID var id: String?
    let profileId: String
    let profileName: String
    let avatar: String
    let score: Int
    let gameType: String
    let difficulty: String
    let level: Int
    let timestamp: Date
    let countryCode: String
    let deviceId: String
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: timestamp)
    }
}

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    private let realtimeDB = Database.database().reference() // Realtime DB for connection check

    
    @Published var globalScores: [GlobalScore] = []
    @Published var isSignedIn = false
    @Published var errorMessage: String?
    @Published var isConnected = false // <-- track connection status

    
    private init() {
        // Configure Firebase if not already
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        signInAnonymouslyIfNeeded()
        observeConnection()
    }
    
    // MARK: - Authentication
    private func signInAnonymouslyIfNeeded() {
          guard auth.currentUser == nil else {
              isSignedIn = true
              print("Firebase already signed in.")
              return
          }
          
          auth.signInAnonymously { [weak self] result, error in
              DispatchQueue.main.async {
                  if let error = error {
                      self?.errorMessage = "Sign-in failed: \(error.localizedDescription)"
                      self?.isSignedIn = false
                      print("Firebase sign-in failed: \(error.localizedDescription)")
                  } else if let user = result?.user {
                      self?.isSignedIn = true
                      print("Signed in anonymously with UID: \(user.uid)")
                  }
              }
          }
      }
    private func observeConnection() {
        let connectedRef = realtimeDB.child(".info/connected")
        connectedRef.observe(.value) { [weak self] snapshot in
            if let connected = snapshot.value as? Bool {
                self?.isConnected = connected
                print("Firebase connection status: \(connected ? "Connected" : "Disconnected")")
            } else {
                self?.isConnected = false
                print("Firebase connection status: Unknown / Disconnected")
            }
        }
    }
    
    func getCurrentUserID() -> String? {
        return auth.currentUser?.uid
    }
    
    // MARK: - Submit Score
    func submitScore(profileId: String,
                     profileName: String,
                     avatar: String,
                     score: Int,
                     gameType: String,
                     difficulty: String,
                     level: Int) {
        
        guard isSignedIn else {
            print("User not signed in yet")
            return
        }
        
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let countryCode = Locale.current.regionCode ?? "unknown"
        
        let scoreData: [String: Any] = [
            "profileId": profileId,
            "profileName": profileName,
            "avatar": avatar,
            "score": score,
            "gameType": gameType,
            "difficulty": difficulty,
            "level": level,
            "timestamp": Timestamp(date: Date()),
            "countryCode": countryCode,
            "deviceId": deviceId
        ]
        
        db.collection("global_leaderboard").addDocument(data: scoreData) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to submit score: \(error.localizedDescription)"
                    print("Error submitting score: \(error)")
                } else {
                    print("Score submitted successfully!")
                }
            }
        }
    }
    
    // MARK: - Fetch Scores
    func fetchGlobalScores(gameType: String, difficulty: String? = nil, limit: Int = 100) {
        var query: Query = db.collection("global_leaderboard")
            .whereField("gameType", isEqualTo: gameType)
            .order(by: "score", descending: true)
            .limit(to: limit)
        
        if let difficulty = difficulty {
            query = query.whereField("difficulty", isEqualTo: difficulty)
        }
        
        query.addSnapshotListener { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to fetch scores: \(error.localizedDescription)"
                    print("Error fetching scores: \(error)")
                    self?.globalScores = []
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self?.globalScores = []
                    return
                }
                
                self?.globalScores = documents.compactMap { doc in
                    try? doc.data(as: GlobalScore.self)
                }
            }
        }
    }
    
    // MARK: - Top Scores
    func fetchTopScores(gameType: String, difficulty: String? = nil, limit: Int = 10) -> [GlobalScore] {
        return globalScores
            .filter { $0.gameType == gameType }
            .filter { difficulty == nil || $0.difficulty == difficulty }
            .sorted { $0.score > $1.score }
            .prefix(limit)
            .map { $0 }
    }
    
    func getUserRank(profileId: String, gameType: String, difficulty: String? = nil) -> Int {
        let sorted = globalScores
            .filter { $0.gameType == gameType }
            .filter { difficulty == nil || $0.difficulty == difficulty }
            .sorted { $0.score > $1.score }
        
        if let index = sorted.firstIndex(where: { $0.profileId == profileId }) {
            return index + 1
        }
        return 0
    }
    
    func clearCache() {
        globalScores = []
    }
}
