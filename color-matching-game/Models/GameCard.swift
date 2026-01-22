import SwiftUI

struct GameCard: Identifiable, Equatable {
    let id = UUID()
    let color: Color
    var isFaceUp: Bool = false
    var isMatched: Bool = false
    
    static func == (lhs: GameCard, rhs: GameCard) -> Bool {
        return lhs.color == rhs.color
    }
}
