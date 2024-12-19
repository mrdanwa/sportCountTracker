import SwiftUI

// Enum to represent different screens in the navigation stack
enum Screen: Hashable {
    case matchSetup(sport: String)
    case pointsView(
        sport: String,
        matchType: MatchType,
        avatars: [String],
        isSetOption: Bool?,
        customSetPoints: Int?
    )
}

struct ContentView: View {
    @State private var path = [Screen]()
    @EnvironmentObject var settings: Settings

    // Mapping each sport to its corresponding color
    let colorMapping: [String: Color] = [
        "Tennis": .green,
        "Badminton": .blue,
        "Ping Pong": .orange,
        "Squash": .yellow,
        "Padel": .purple,
        "Football": .white,
        "Custom": .pink
    ]

    var body: some View {
        NavigationStack(path: $path) {
            List {
                // Title
                Text("SELECT SPORT")
                    .font(.headline)
                    .padding()
                    .listRowBackground(Color.clear)
                
                // Filtered Sports
                ForEach(settings.sports.filter { settings.selectedSports.contains($0) }, id: \.self) { sport in
                    let color = colorMapping[sport] ?? .gray
                    Button(action: {
                        path.append(.matchSetup(sport: sport))
                    }) {
                        HStack {
                            Image(systemName: icon(for: sport))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(color)
                                .padding(.leading, 20)
                            
                            Text(sport)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(color)
                                .padding(.leading, 10)
                        }
                        .padding(.vertical, 35)
                    }
                    .frame(maxWidth: .infinity)
                    .background(color.opacity(0.2))
                    .cornerRadius(20)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                // History Navigation
                NavigationLink(destination: HistoryView()) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.green)
                            .padding(.leading, 20)
                        
                        Text("History")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.green)
                            .padding(.leading, 10)
                    }
                    .padding(.vertical, 35)
                }
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.2))
                .cornerRadius(20)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

                // Settings Navigation
                NavigationLink(destination: SettingsView()) {
                    HStack {
                        Image(systemName: "gear")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.gray)
                            .padding(.leading, 25)
                        
                        Text("Settings")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                    }
                    .padding(.vertical, 35)
                }
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(20)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

                Spacer()
                    .frame(height: 50)
                    .listRowBackground(Color.clear)
            }
            .listStyle(CarouselListStyle())
            .navigationDestination(for: Screen.self) { screen in
                switch screen {
                case .matchSetup(let sport):
                    MatchSetupView(sport: sport, path: $path)
                case .pointsView(let sport, let matchType, let avatars, let isSetOption, let customSetPoints):
                    PointsView(
                        sport: sport,
                        matchType: matchType,
                        avatars: avatars,
                        isSetOption: isSetOption,
                        customSetPoints: customSetPoints,
                        path: $path
                    )
                }
            }
            .navigationBarHidden(false)
        }
    }
    
    // Returns the icon name for each sport
    func icon(for sport: String) -> String {
        switch sport {
        case "Tennis": return "figure.tennis"
        case "Badminton": return "figure.badminton"
        case "Ping Pong": return "figure.table.tennis"
        case "Squash": return "figure.squash"
        case "Padel": return "tennisball.fill"
        case "Football": return "soccerball"
        case "Custom": return "person.3.sequence"
        default: return "questionmark.circle"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
