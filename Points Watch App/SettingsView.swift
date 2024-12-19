import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: Settings
    @State private var showMenuView = false

    var body: some View {
        VStack {
            menuViewButton()
            Spacer()
        }
        .padding()
        .padding(.top, 10)
        .navigationTitle("Settings")
    }

    // MARK: - UI Components

    func menuViewButton() -> some View {
        HStack {
            Text("Menu View")
                .font(.system(size: 14))
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .onTapGesture {
            showMenuView = true
        }
        .sheet(isPresented: $showMenuView) {
            MenuView()
                .environmentObject(settings)
        }
    }
}

struct MenuView: View {
    @EnvironmentObject var settings: Settings

    var isSmallScreen: Bool {
        WKInterfaceDevice.current().screenBounds.width < 170
    }

    var body: some View {
        ScrollView {
            VStack {
                let sortedSports = settings.sports.filter { settings.selectedSports.contains($0) } +
                                   settings.sports.filter { !settings.selectedSports.contains($0) }

                ForEach(sortedSports, id: \.self) { sport in
                    let isSelected = settings.selectedSports.contains(sport)
                    if let index = settings.sports.firstIndex(of: sport) {
                        reorderableRow(for: index, sport: sport, isSelected: isSelected)
                    }
                }
                
                Spacer()
                    .frame(height: 30)
            }
        }
        .padding()
        .edgesIgnoringSafeArea(.bottom)
    }

    // MARK: - UI Components

    private func reorderableRow(for index: Int, sport: String, isSelected: Bool) -> some View {
        HStack {
            if isSelected {
                moveUpButton(for: index)
            }
            sportToggle(for: sport)
        }
        .padding(.vertical, 15)
        .padding(.horizontal)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }

    private func moveUpButton(for index: Int) -> some View {
        Button(action: {
            moveItemUp(from: index)
        }) {
            Image(systemName: "arrow.up")
                .resizable()
                .frame(width: isSmallScreen ? 10 : 12, height: isSmallScreen ? 10 : 12)
                .foregroundColor(.blue)
        }
        .buttonStyle(.plain)
        .padding(.trailing, isSmallScreen ? 5 : 10)
    }

    private func sportToggle(for sport: String) -> some View {
        Toggle(isOn: Binding(
            get: { settings.selectedSports.contains(sport) },
            set: { isSelected in
                if isSelected {
                    settings.selectedSports.insert(sport)
                } else {
                    settings.selectedSports.remove(sport)
                }
            }
        )) {
            Text(sport)
                .font(.system(size: isSmallScreen ? 12 : 14))
        }
    }

    private func moveItemUp(from index: Int) {
        guard index > 0 else { return }
        if settings.selectedSports.contains(settings.sports[index]) &&
            settings.selectedSports.contains(settings.sports[index - 1]) {
            settings.sports.swapAt(index, index - 1)
        }
    }
}
