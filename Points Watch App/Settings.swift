import Foundation
import Combine

class Settings: ObservableObject {
    @Published var sports: [String] = [
        "Tennis",
        "Badminton",
        "Ping Pong",
        "Squash",
        "Padel",
        "Football",
        "Custom"
    ] {
        didSet {
            saveSports()
        }
    }

    @Published var selectedSports: Set<String> = [
        "Tennis",
        "Badminton",
        "Ping Pong",
        "Squash",
        "Padel",
        "Football",
        "Custom"
    ] {
        didSet {
            saveSelectedSports()
        }
    }

    init() {
        loadSports()
        loadSelectedSports()
    }

    private func saveSports() {
        UserDefaults.standard.set(sports, forKey: "sports")
    }

    private func loadSports() {
        if let savedSports = UserDefaults.standard.stringArray(forKey: "sports") {
            sports = savedSports
        }
    }

    private func saveSelectedSports() {
        let sportsArray = Array(selectedSports)
        UserDefaults.standard.set(sportsArray, forKey: "selectedSports")
    }

    private func loadSelectedSports() {
        if let savedSports = UserDefaults.standard.stringArray(forKey: "selectedSports") {
            selectedSports = Set(savedSports)
        }
    }
}
