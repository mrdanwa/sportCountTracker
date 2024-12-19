# PointsApp

PointsApp is a SwiftUI-based watchOS app for tracking scores in various sports matches. This application allows you to quickly select a sport, set up a match type (1 vs 1 or 2 vs 2), optionally define a custom scoring system, and start keeping track of points and sets right from your wrist. The app also provides a match history feature, enabling you to review past matches and recall previous scores. Additionally, you can customize which sports appear in your main menu through the Settings feature.

## Features

- **Sport Selection:** Choose from multiple sports like Tennis, Badminton, Ping Pong, Squash, Padel, Football, or define a Custom sport.
- **Match Setup:** Decide the scoring type (Set vs No Set), points per set (if applicable), and select player or team avatars.
- **Real-time Scoring:** Increment scores for each side, see scores update live, and track sets and points as you play.
- **Match History:** Review up to 25 of your most recent matches, complete with date, sport, and final scores.
- **Customization:** Use the built-in Settings to reorder and toggle the visibility of sports in your main menu, tailoring the app to your preferences.
- **Timer Functionality:** Keep track of elapsed match time. Start, pause, and resume the timer as needed.
- **Undo Actions:** Mistakenly added a point? Use the undo button to revert to a previous state.

## Getting Started

- **Navigation:**
  - **Home Screen:** Scroll through the list of available sports and choose one to start setting up a match.
  - **Match Setup:** Follow the on-screen prompts to configure your match and select avatars for the players.
  - **Scoring View:** Track points, sets, and elapsed time. Use the top-left button to return to the home screen, the undo button to revert scores, the timer button to pause/play time, and the end match button to finalize the results.
  - **History:** Access past matches from the home screen’s History button.
  - **Settings:** Customize which sports appear in the main menu via the Settings option.

- **Customization:**
  - **Adding/Removing Sports:** Use the toggle switches in the Menu View (accessible through Settings) to show or hide sports.
  - **Reordering Sports:** Press the "arrow up" icon next to a selected sport to move it higher in the list.

## Project Structure

- **PointsApp.swift:** App entry point, initializing `MatchHistory` and `Settings` environment objects.
- **ContentView.swift:** Main view displaying the list of sports, navigation to History and Settings.
- **MatchSetupView.swift:** Guides the user through match configuration steps (type, avatars, set options).
- **PointsView.swift:** The main scoring interface, including timer, undo, and end match functions.
- **HistoryView.swift:** Displays recorded matches, grouped by date. Provides a clear history option.
- **Match.swift & MatchHistory.swift:** Data models for matches and persistent storage.
- **Settings.swift & SettingsView.swift:** User preferences for displayed sports and order. Provides a reordering interface.

## License

This project is distributed under the MIT License. See [LICENSE](LICENSE) for details.
