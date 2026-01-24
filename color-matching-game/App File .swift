import SwiftUI

@main
struct MultiGameApp: App {
    @StateObject private var profileManager = ProfileManager()
    
    var body: some Scene {
        WindowGroup {
            MainMenuView()
                .environmentObject(profileManager)
        }
    }
}
