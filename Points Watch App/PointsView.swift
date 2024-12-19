import SwiftUI

struct PointsView: View {
    var sport: String
    var matchType: MatchType
    var avatars: [String]
    var isSetOption: Bool?
    var customSetPoints: Int?

    @EnvironmentObject var history: MatchHistory

    @State private var pointsP1 = 0
    @State private var pointsP2 = 0
    @State private var setsP1 = 0
    @State private var setsP2 = 0

    @State private var elapsedTime: Int = 0
    @State private var timer: Timer?
    @State private var isTimerPaused: Bool = false

    @State private var actionHistory: [(pointsP1: Int, pointsP2: Int, setsP1: Int, setsP2: Int)] = []

    @State private var activeAlert: ActiveAlert?

    @State private var showLoader = true
    @State private var countdown = 3
    @State private var progress: CGFloat = 0.0

    enum ActiveAlert: Identifiable {
        case endMatch, back
        var id: Int { hashValue }
    }

    var noSet: Bool {
        if sport == "Custom" {
            return isSetOption == false
        } else {
            return ["Football"].contains(sport)
        }
    }

    private let isLargeScreen: Bool = WKInterfaceDevice.current().screenBounds.width > 190

    var maxPoints: Int {
        switch sport {
        case "Badminton": return 21
        case "Squash", "Ping Pong": return 11
        case "Tennis", "Padel": return 4
        case "Custom": return customSetPoints ?? 10
        default: return 10
        }
    }

    @Binding var path: [Screen]

    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    Text("\(setsP1) : \(setsP2)")
                        .font(setsP1 >= 100 || setsP2 >= 100 ? .title2 : .largeTitle)
                        .fontWeight(.heavy)
                        .padding(setsP1 >= 100 || setsP2 >= 100 ? 10 : 5)
                        .frame(maxWidth: .infinity)
                        .background(getBackgroundColor())
                        .cornerRadius(20)

                    HStack(spacing: 5) {
                        playerButton(for: 1)
                        playerButton(for: 2)
                    }

                    HStack {
                        undoButton()
                        timerButton()
                        endMatchButton()
                    }
                }
            }
            .navigationTitle("\(formattedTime())")
            .navigationBarHidden(false)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    customBackButton()
                }
            }
            .onDisappear { stopTimer() }
            .alert(item: $activeAlert) { alert in
                alertView(for: alert)
            }

            if showLoader {
                countdownLoader()
            }
        }
    }

    // MARK: - UI Components

    func playerButton(for player: Int) -> some View {
        VStack {
            Button(action: {
                player == 1 ? incrementP1() : incrementP2()
            }) {
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(player == 1 ? Color.green.opacity(0.7) : Color.blue.opacity(0.7))

                    Text(noSet ? "+" : "\(displayScore(points: player == 1 ? pointsP1 : pointsP2))")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding([.top, .bottom], 25)

                    avatarImage(for: player)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    func avatarImage(for player: Int) -> some View {
        HStack {
            if matchType == .oneVsOne {
                Image(systemName: avatars[player - 1])
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: avatars[player * 2 - 2])
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                Image(systemName: avatars[player * 2 - 1])
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
        }
        .padding(5)
    }

    func undoButton() -> some View {
        Button(action: redoLastAction) {
            Image(systemName: "arrow.uturn.backward.circle")
                .resizable()
                .frame(width: isLargeScreen ? 50 : 40, height: isLargeScreen ? 50 : 40)
                .foregroundColor(.orange)
        }
        .buttonStyle(PlainButtonStyle())
        .padding()
    }

    func timerButton() -> some View {
        Button(action: {
            toggleTimer()
        }) {
            Image(systemName: isTimerPaused ? "play.circle" : "pause.circle")
                .resizable()
                .frame(width: isLargeScreen ? 50 : 40, height: isLargeScreen ? 50 : 40)
                .foregroundColor(.yellow)
        }
        .buttonStyle(PlainButtonStyle())
    }

    func endMatchButton() -> some View {
        Button(action: {
            activeAlert = .endMatch
        }) {
            Image(systemName: "flag.circle")
                .resizable()
                .frame(width: isLargeScreen ? 50 : 40, height: isLargeScreen ? 50 : 40)
                .foregroundColor(.red)
        }
        .buttonStyle(PlainButtonStyle())
        .padding()
    }

    func customBackButton() -> some View {
        Button(action: {
            if pointsP1 > 0 || pointsP2 > 0 || setsP1 > 0 || setsP2 > 0 {
                activeAlert = .back
            } else {
                path = []
            }
        }) {
            HStack {
                Image(systemName: "chevron.left")
            }
        }
    }

    func alertView(for alert: ActiveAlert) -> Alert {
        switch alert {
        case .endMatch:
            return Alert(
                title: Text("End Match"),
                message: Text("Are you sure you want to end the match?"),
                primaryButton: .destructive(Text("End Match")) {
                    resetMatch()
                    path = []
                },
                secondaryButton: .cancel()
            )
        case .back:
            return Alert(
                title: Text("End Match"),
                message: Text("Are you sure you want to end the match and go back?"),
                primaryButton: .destructive(Text("End Match")) {
                    resetMatch()
                    path = []
                },
                secondaryButton: .cancel()
            )
        }
    }

    func countdownLoader() -> some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(.blue)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .foregroundColor(.blue)
                    .rotationEffect(Angle(degrees: -90))
                    .frame(width: 100, height: 100)
                
                Text("\(countdown)")
                    .font(.system(size: 80))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            startCountdown()
        }
        .animation(nil, value: showLoader)
    }

    // MARK: - Timer & Countdown

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func toggleTimer() {
        if isTimerPaused {
            startTimer()
        } else {
            stopTimer()
        }
        isTimerPaused.toggle()
    }

    func formattedTime() -> String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func startCountdown() {
        withAnimation(.linear(duration: 3)) {
            self.progress = 1.0
        }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.countdown > 1 {
                self.countdown -= 1
            } else {
                timer.invalidate()
                self.showLoader = false
                startTimer()
            }
        }
    }

    // MARK: - Scoring & Match Logic

    func displayScore(points: Int) -> String {
        switch sport {
        case "Tennis", "Padel":
            return tennisPadelScore(points: points)
        case "Badminton", "Squash", "Ping Pong":
            return "\(points)"
        default:
            return "\(points)"
        }
    }

    func tennisPadelScore(points: Int) -> String {
        if pointsP1 >= 3 && pointsP2 >= 3 {
            if pointsP1 == pointsP2 { return "D" }   // Deuce
            return pointsP1 > pointsP2 ? "A1" : "A2" // Advantage
        }

        switch points {
        case 0: return "0"
        case 1: return "15"
        case 2: return "30"
        case 3: return "40"
        default: return "Game"
        }
    }

    func incrementP1() {
        saveCurrentState()
        switch sport {
        case "Tennis", "Padel":
            incrementTennisPadel(player: 1)
        case "Badminton", "Squash", "Ping Pong":
            incrementBadmintonSquashPingPong(player: 1)
        case "Custom":
            if let isSetOption = isSetOption, isSetOption {
                incrementCustomSport(player: 1)
            } else {
                setsP1 += 1
            }
        default:
            setsP1 += 1
        }
    }

    func incrementP2() {
        saveCurrentState()
        switch sport {
        case "Tennis", "Padel":
            incrementTennisPadel(player: 2)
        case "Badminton", "Squash", "Ping Pong":
            incrementBadmintonSquashPingPong(player: 2)
        case "Custom":
            if let isSetOption = isSetOption, isSetOption {
                incrementCustomSport(player: 2)
            } else {
                setsP2 += 1
            }
        default:
            setsP2 += 1
        }
    }

    func incrementCustomSport(player: Int) {
        guard let pointsPerSet = customSetPoints else { return }
        if player == 1 {
            pointsP1 += 1
            if pointsP1 >= pointsPerSet && (pointsP1 - pointsP2) >= 2 {
                winGame(player: 1)
            }
        } else {
            pointsP2 += 1
            if pointsP2 >= pointsPerSet && (pointsP2 - pointsP1) >= 2 {
                winGame(player: 2)
            }
        }
    }

    func incrementTennisPadel(player: Int) {
        if player == 1 {
            if pointsP1 == 3 && pointsP2 < 3 {
                winGame(player: 1)
            } else if pointsP1 >= 3 && pointsP2 >= 3 {
                if pointsP1 == pointsP2 {
                    pointsP1 += 1
                } else if pointsP1 > pointsP2 {
                    winGame(player: 1)
                } else {
                    pointsP1 += 1
                }
            } else {
                pointsP1 += 1
            }
        } else {
            if pointsP2 == 3 && pointsP1 < 3 {
                winGame(player: 2)
            } else if pointsP2 >= 3 && pointsP1 >= 3 {
                if pointsP2 == pointsP1 {
                    pointsP2 += 1
                } else if pointsP2 > pointsP1 {
                    winGame(player: 2)
                } else {
                    pointsP2 += 1
                }
            } else {
                pointsP2 += 1
            }
        }
    }

    func incrementBadmintonSquashPingPong(player: Int) {
        let maxThreshold = sport == "Badminton" ? 20 : 10
        if player == 1 {
            if pointsP1 >= maxThreshold && (pointsP1 - pointsP2) >= 2 {
                winGame(player: 1)
            } else {
                pointsP1 += 1
            }
        } else {
            if pointsP2 >= maxThreshold && (pointsP2 - pointsP1) >= 2 {
                winGame(player: 2)
            } else {
                pointsP2 += 1
            }
        }
    }

    func winGame(player: Int) {
        if player == 1 {
            setsP1 += 1
        } else {
            setsP2 += 1
        }
        resetPoints()
    }

    func saveCurrentState() {
        actionHistory.append((pointsP1: pointsP1, pointsP2: pointsP2, setsP1: setsP1, setsP2: setsP2))
    }

    func redoLastAction() {
        guard !actionHistory.isEmpty else { return }
        let lastState = actionHistory.removeLast()
        pointsP1 = lastState.pointsP1
        pointsP2 = lastState.pointsP2
        setsP1 = lastState.setsP1
        setsP2 = lastState.setsP2
    }

    func resetPoints() {
        pointsP1 = 0
        pointsP2 = 0
    }

    func resetMatch() {
        history.addMatch(Match(sport: sport, pointsP1: setsP1, pointsP2: setsP2, matchType: matchType, avatars: avatars))
        pointsP1 = 0
        pointsP2 = 0
        setsP1 = 0
        setsP2 = 0
        actionHistory.removeAll()
    }

    func getBackgroundColor() -> Color {
        if setsP1 > setsP2 {
            return Color.green.opacity(0.7)
        } else if setsP2 > setsP1 {
            return Color.blue.opacity(0.7)
        } else {
            return Color.gray.opacity(0.7)
        }
    }
}

struct PointsView_Previews: PreviewProvider {
    @State static var path: [Screen] = []
    static var previews: some View {
        PointsView(
            sport: "Tennis",
            matchType: .oneVsOne,
            avatars: ["person.fill", "person.fill", "person.fill", "person.fill"],
            isSetOption: true,
            customSetPoints: 10,
            path: $path
        )
        .environmentObject(MatchHistory())
    }
}
