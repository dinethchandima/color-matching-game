import SwiftUI

struct DifficultyInfoRow: View {
    let level: String
    let gridSize: String
    let time: String
    let hints: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(level)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text(gridSize)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label(time, systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Label(hints, systemImage: "lightbulb.fill")
                    .font(.caption)
                    .foregroundColor(.purple)
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
