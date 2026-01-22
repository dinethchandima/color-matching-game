import SwiftUI

struct DifficultyCardView: View {
    let difficulty: DifficultyLevel
    
    var backgroundColor: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    var icon: String {
        switch difficulty {
        case .easy: return "star.fill"
        case .medium: return "star.leadinghalf.filled"
        case .hard: return "star"
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(difficulty.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                HStack {
                    Label("\(difficulty.gridSize)×\(difficulty.gridSize)", systemImage: "square.grid.2x2")
                        .font(.caption)
                    
                    Spacer()
                    
                    Label("\(difficulty.timeLimit)s", systemImage: "clock")
                        .font(.caption)
                    
                    Spacer()
                    
                    Label("\(difficulty.hintCount)", systemImage: "lightbulb.fill")
                        .font(.caption)
                }
                .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.title3)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(15)
        .shadow(color: backgroundColor.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}
