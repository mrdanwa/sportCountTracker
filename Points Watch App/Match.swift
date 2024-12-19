import Foundation
import Combine

enum MatchType: String, Codable {
    case oneVsOne
    case twoVsTwo
}

struct Match: Identifiable, Codable {
    let id: UUID
    let sport: String
    let pointsP1: Int
    let pointsP2: Int
    var matchType: MatchType
    var avatars: [String]
    let date: Date
    
    init(
        id: UUID = UUID(),
        sport: String,
        pointsP1: Int,
        pointsP2: Int,
        matchType: MatchType,
        avatars: [String],
        date: Date = Date()
    ) {
        self.id = id
        self.sport = sport
        self.pointsP1 = pointsP1
        self.pointsP2 = pointsP2
        self.matchType = matchType
        self.avatars = avatars
        self.date = date
    }
}

class MatchHistory: ObservableObject {
    @Published var matches: [Match] = [] {
        didSet {
            saveMatches()
        }
    }

    init() {
        loadMatches()
    }

    func addMatch(_ match: Match) {
        matches.insert(match, at: 0)
        if matches.count > 25 {
            matches.removeLast()
        }
    }

    func clearHistory() {
        matches.removeAll()
    }

    private func saveMatches() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(matches) {
            UserDefaults.standard.set(data, forKey: "matches")
        }
    }

    private func loadMatches() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: "matches"),
           let decodedMatches = try? decoder.decode([Match].self, from: data) {
            matches = decodedMatches
        }
    }
}
