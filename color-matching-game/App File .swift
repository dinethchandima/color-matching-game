import SwiftUI
import Firebase




@main
struct MultiGameApp: App {
    @StateObject private var profileManager = ProfileManager()
    init() {
           FirebaseApp.configure()
       }
    
    var body: some Scene {
        WindowGroup {
            MainMenuView()
                .environmentObject(profileManager)
        }
    }
}
