import SwiftUI

struct MainMenuView: View {
    @StateObject private var profileManager = ProfileManager()
    @State private var showingProfileSelection = false
    @State private var showingCreateProfile = false
    @State private var newProfileName = ""
    @State private var selectedAvatar = "person.circle.fill"
    
    let avatars = [
        "person.circle.fill",
        "person.fill",
        "person.2.fill",
        "person.3.fill",
        "gamecontroller.fill",
        "brain.head.profile",
        "star.fill",
        "crown.fill",
        "flag.fill",
        "heart.fill"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 10) {
                        if let profile = profileManager.currentProfile {
                            HStack {
                                Image(systemName: profile.avatar)
                                    .font(.system(size: 50))
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(profile.name)
                                        .font(.title)
                                        .fontWeight(.bold)
                                    
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                        Text("Total Score: \(profile.totalScore)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "gamecontroller.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                        Text("Games: \(profile.totalGamesPlayed)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    showingProfileSelection = true
                                }) {
                                    Image(systemName: "person.crop.circle.badge.plus")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        
                        Text("Game Center")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal)
                    
                    // Games Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(GameType.allCases, id: \.self) { game in
                            GameCardView(game: game, profileManager: profileManager)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Quick Stats
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Quick Stats")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        if let profile = profileManager.currentProfile {
                            HStack {
                                StatCard(
                                    title: "Total Games",
                                    value: "\(profile.totalGamesPlayed)",
                                    icon: "gamecontroller.fill",
                                    color: .green
                                )
                                
                                StatCard(
                                    title: "Total Score",
                                    value: "\(profile.totalScore)",
                                    icon: "star.fill",
                                    color: .yellow
                                )
                                
                                StatCard(
                                    title: "Levels",
                                    value: "\(profile.unlockedLevels.values.reduce(0, +))",
                                    icon: "chart.bar.fill",
                                    color: .blue
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                    
                    // Instructions
                    VStack(spacing: 10) {
                        Text("Select a game to play!")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Create multiple profiles for family & friends")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 30)
                }
                .padding(.top, 20)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingProfileSelection) {
            ProfileSelectionView(
                profileManager: profileManager,
                showingCreateProfile: $showingCreateProfile
            )
        }
        .sheet(isPresented: $showingCreateProfile) {
            CreateProfileView(
                profileManager: profileManager,
                newProfileName: $newProfileName,
                selectedAvatar: $selectedAvatar,
                avatars: avatars
            )
        }
    }
}

struct GameCardView: View {
    let game: GameType
    @ObservedObject var profileManager: ProfileManager
    
    var body: some View {
        NavigationLink(destination: destinationView) {
            VStack(spacing: 15) {
                Image(systemName: game.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .background(gameGradient)
                    .clipShape(Circle())
                    .shadow(color: gameGradient.stops[0].color.opacity(0.3), radius: 5, x: 0, y: 3)
                
                Text(game.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(game.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 5)
                
                // Show highest unlocked level
                if let profile = profileManager.currentProfile {
                    let level = profile.getLevel(for: game)
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("Level \(level)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var gameGradient: LinearGradient {
        switch game {
        case .memoryMatch:
            return LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .colorMatch:
            return LinearGradient(
                colors: [Color.green, Color.blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var destinationView: some View {
        Group {
            switch game {
            case .memoryMatch:
                MemoryGameView()
                    .environmentObject(profileManager)
            case .colorMatch:
                ColorMatchLevelView()
                    .environmentObject(profileManager)
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Profile Selection View
struct ProfileSelectionView: View {
    @ObservedObject var profileManager: ProfileManager
    @Binding var showingCreateProfile: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if profileManager.profiles.isEmpty {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 80))
                            .foregroundColor(.gray.opacity(0.3))
                        
                        Text("No Profiles Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("Create your first profile to start playing!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(profileManager.profiles) { profile in
                                ProfileRowView(
                                    profile: profile,
                                    isSelected: profileManager.currentProfile?.id == profile.id,
                                    action: {
                                        profileManager.selectProfile(profile)
                                        dismiss()
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
                
                Button(action: {
                    showingCreateProfile = true
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create New Profile")
                            .fontWeight(.semibold)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationTitle("Select Profile")
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

struct ProfileRowView: View {
    let profile: GameProfile
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: profile.avatar)
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                    .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(profile.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack {
                        HStack {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text("\(profile.totalScore)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        HStack {
                            Image(systemName: "gamecontroller.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text("\(profile.totalGamesPlayed)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text("Last played: \(formattedDate(profile.lastPlayed))")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Create Profile View
struct CreateProfileView: View {
    @ObservedObject var profileManager: ProfileManager
    @Binding var newProfileName: String
    @Binding var selectedAvatar: String
    let avatars: [String]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Details")) {
                    TextField("Enter your name", text: $newProfileName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Select an avatar:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(avatars, id: \.self) { avatar in
                                Button(action: {
                                    selectedAvatar = avatar
                                }) {
                                    Image(systemName: avatar)
                                        .font(.system(size: 40))
                                        .foregroundColor(selectedAvatar == avatar ? .white : .blue)
                                        .frame(width: 60, height: 60)
                                        .background(selectedAvatar == avatar ? Color.blue : Color.blue.opacity(0.1))
                                        .clipShape(Circle())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
            .navigationTitle("Create Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        if !newProfileName.isEmpty {
                            profileManager.createProfile(name: newProfileName, avatar: selectedAvatar)
                            newProfileName = ""
                            selectedAvatar = "person.circle.fill"
                            dismiss()
                        }
                    }
                    .disabled(newProfileName.isEmpty)
                }
            }
        }
    }
}
