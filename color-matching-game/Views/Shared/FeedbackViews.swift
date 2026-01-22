import SwiftUI

struct MatchFeedbackView: View {
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

struct HintActiveIndicator: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .font(.caption)
                .foregroundColor(.yellow)
            
            Text("Hint Active - Finding a match...")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.yellow)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: true)
    }
}
