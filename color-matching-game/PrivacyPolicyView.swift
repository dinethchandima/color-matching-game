import SwiftUI

struct PrivacyPolicyView: View {
    @ObservedObject var profileManager: ProfileManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Privacy Policy")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Last updated: \(Date(), formatter: dateFormatter)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(15)
                    
                    // Privacy Policy Content
                    VStack(alignment: .leading, spacing: 15) {
                        SectionView(
                            title: "1. Information We Collect",
                            content: """
                            We collect anonymous gameplay data including:
                            • Scores and achievements
                            • Game progress and levels completed
                            • Device information (for technical support)
                            • Country/region for leaderboard rankings
                            
                            We do NOT collect:
                            • Personal identification information
                            • Email addresses or contact details
                            • Location data beyond country level
                            • Payment information
                            """
                        )
                        
                        SectionView(
                            title: "2. How We Use Your Information",
                            content: """
                            • To provide global leaderboard functionality
                            • To improve game performance and features
                            • To analyze gameplay trends anonymously
                            • To prevent cheating and ensure fair play
                            """
                        )
                        
                        SectionView(
                            title: "3. Data Storage & Security",
                            content: """
                            • Data is stored securely on Firebase servers
                            • All data is encrypted in transit and at rest
                            • We use anonymous identifiers instead of personal data
                            • You can delete your data at any time through app settings
                            """
                        )
                        
                        SectionView(
                            title: "4. Third-Party Services",
                            content: """
                            We use Firebase (Google) for:
                            • Anonymous authentication
                            • Cloud storage of scores
                            • Leaderboard functionality
                            
                            Firebase's privacy policy applies to their services.
                            """
                        )
                        
                        SectionView(
                            title: "5. Your Rights",
                            content: """
                            • Access your anonymous gameplay data
                            • Delete your data from our servers
                            • Opt-out of global leaderboards
                            • Export your game progress
                            """
                        )
                        
                        SectionView(
                            title: "6. Children's Privacy",
                            content: """
                            Our game is suitable for all ages. We:
                            • Do not collect personal information from children
                            • Provide parental controls
                            • Offer easy profile deletion
                            • Comply with COPPA regulations
                            """
                        )
                    }
                    .padding()
                    
                    // Agreement Section
                    VStack(spacing: 15) {
                        Text("By accepting this policy, you agree to:")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            AgreementPoint(text: "Anonymous data collection for gameplay")
                            AgreementPoint(text: "Storage of scores on global leaderboards")
                            AgreementPoint(text: "Use of Firebase services")
                            AgreementPoint(text: "Basic device information collection")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding()
                    
                    // Action Buttons
                    VStack(spacing: 15) {
                        if profileManager.isLoading {
                            ProgressView("Connecting to leaderboards...")
                                .padding()
                        }
                        
                        PrimaryButton(
                            title: "Accept & Continue",
                            icon: "checkmark.circle.fill",
                            color: .green,
                            action: {
                                profileManager.acceptPrivacyPolicy()
                            }
                        )
                        .disabled(profileManager.isLoading)
                        
                        SecondaryButton(
                            title: "Decline (Play Offline)",
                            icon: "xmark.circle.fill",
                            color: .red,
                            action: {
                                dismiss()
                            }
                        )
                        .disabled(profileManager.isLoading)
                        
                        Text("Declining will limit you to local gameplay only")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
}

struct SectionView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct AgreementPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

struct PrimaryButton1: View {
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
            .font(.title3)
            .foregroundColor(.white)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(15)
            .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
}

struct SecondaryButton2: View {
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
