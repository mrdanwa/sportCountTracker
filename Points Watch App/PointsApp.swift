import SwiftUI

@main
struct PointsApp: App {
    @StateObject var history = MatchHistory()
    @StateObject var settings = Settings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(history)
                .environmentObject(settings)
        }
    }
}
