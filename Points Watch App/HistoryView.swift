import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var history: MatchHistory

    var body: some View {
        ScrollView {
            VStack {
                if history.matches.isEmpty {
                    emptyHistoryView()
                } else {
                    matchHistoryView()
                    clearButton()
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    // MARK: - Views

    func emptyHistoryView() -> some View {
        VStack {
            Spacer()
            Text("No matches recorded yet")
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer()
        }
    }

    func matchHistoryView() -> some View {
        let groupedMatches = Dictionary(
            grouping: history.matches.prefix(15).sorted(by: { $0.date > $1.date }),
            by: { formattedDate(from: $0.date) }
        )

        return VStack {
            ForEach(groupedMatches.keys.sorted(by: { $0 > $1 }), id: \.self) { date in
                dateSectionView(date: date, matches: groupedMatches[date] ?? [])
            }
            Spacer()
        }
    }

    func dateSectionView(date: String, matches: [Match]) -> some View {
        VStack(alignment: .center) {
            Text(date)
                .font(.headline)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Divider()
            
            ForEach(matches) { match in
                matchDetailView(match: match)
            }
        }
        .padding(.bottom, 10)
    }

    func matchDetailView(match: Match) -> some View {
        VStack {
            Text(match.sport)
                .font(.subheadline)
                .fontWeight(.bold)
            
            HStack {
                if match.matchType == .oneVsOne {
                    oneVsOneView(match: match)
                } else {
                    twoVsTwoView(match: match)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.leading, 10)
    }

    func oneVsOneView(match: Match) -> some View {
        HStack {
            Image(systemName: match.avatars[0])
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)

            Text("\(match.pointsP1) - \(match.pointsP2)")
                .padding(.horizontal, 5)

            Image(systemName: match.avatars[1])
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
        }
    }

    func twoVsTwoView(match: Match) -> some View {
        HStack {
            VStack(spacing: 5) {
                Image(systemName: match.avatars[0])
                    .resizable()
                    .frame(width: 20, height: 20)
                Image(systemName: match.avatars[1])
                    .resizable()
                    .frame(width: 20, height: 20)
            }

            Text("\(match.pointsP1) - \(match.pointsP2)")
                .padding(.horizontal, 5)

            VStack(spacing: 5) {
                Image(systemName: match.avatars[2])
                    .resizable()
                    .frame(width: 20, height: 20)
                Image(systemName: match.avatars[3])
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        }
    }

    func clearButton() -> some View {
        Button(action: history.clearHistory) {
            Text("Clear")
                .font(.callout)
                .padding(8)
                .background(Color.red.opacity(0.2))
                .foregroundColor(.red)
                .cornerRadius(8)
        }
        .frame(width: 90, height: 30)
        .buttonStyle(PlainButtonStyle())
        .padding(.bottom, 20)
    }

    // MARK: - Helper

    func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}
