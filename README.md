# 💧 Water Reminder

A premium, high-performance Flutter application designed to help users maintain healthy hydration levels through smart reminders and elegant tracking.

![App Preview](https://via.placeholder.com/800x400?text=Water+Reminder+Premium+UI)

## ✨ Features

*   **Glassmorphic Dashboard**: A state-of-the-art UI featuring real-time progress tracking with smooth, direct animations.
*   **Smart Reminders**: Fully customizable drink intervals with persistent background service support.
*   **Custom Soundscapes**: Choose from various notification sounds (Water Drop, Chime, Bubbles, Ding) to personalize your experience.
*   **Hydration History**: Integrated `TableCalendar` view to visualize your success and consistency over time.
*   **Intelligent Logic**: Features a unique "Logical Date" system that handles late-night hydration correctly by resetting the day at 6:00 AM.
*   **Offline First**: All your data is stored locally and securely using `SharedPreferences`.

## 🛠️ Technical Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Background Tasks**: `flutter_background_service`
- **Notifications**: `flutter_local_notifications`
- **Audio**: `audioplayers`
- **UI Components**: `percent_indicator`, `table_calendar`

## 🚀 Getting Started

### Prerequisites

*   Flutter SDK (v3.1.0 or higher)
*   Android Studio / VS Code
*   A physical device or emulator

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/yourusername/water_reminder.git
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the application**
    ```bash
    flutter run
    ```

## 📱 Permissions Required

To provide the best experience, the app requires:
*   **Post Notifications**: To send you water reminders.
*   **Schedule Exact Alarms**: To ensure reminders hit exactly on your preferred interval.
*   **Background Service**: To keep the timer running while you're away.

---

*Developed with ❤️ focusing on health and premium UX.*
