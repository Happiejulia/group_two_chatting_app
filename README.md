Mobile App assignment 

1. create a flutter app for Chatting using Firebase
REQUIREMENTS

User Authentication
View other users
Send and receive text
Receive Notifications
[project should be in a github, SHOWING ALL MEMBERS' PERTICIPATION]



# Group Two Chatting App

A professional Flutter chat application with Firebase integration, featuring real-time messaging, user authentication, and a modern Material Design 3 interface.

## Features

- **User Authentication**: Secure login and registration using Firebase Authentication
- **Real-time Chat**: Instant messaging with Firebase Firestore for data persistence
- **Chat Lists**: View and manage multiple chat conversations
- **Dark Mode**: Toggle between light and dark themes with persistent preferences
- **Settings Screen**: User preferences and app configuration
- **Cross-platform**: Built with Flutter for iOS, Android, Web, and Desktop
- **Material Design 3**: Modern UI components and theming

## Technologies Used

- **Flutter**: Cross-platform UI framework
- **Firebase Core**: Firebase initialization and configuration
- **Firebase Auth**: User authentication services
- **Cloud Firestore**: NoSQL database for real-time data
- **Provider**: State management solution
- **Shared Preferences**: Local storage for user preferences
- **Flutter Launcher Icons**: Custom app icons

## Prerequisites

Before running this project, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.10.4 or higher)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- [Firebase CLI](https://firebase.google.com/docs/cli) (for Firebase setup)
- A code editor like [Visual Studio Code](https://code.visualstudio.com/) with Flutter extensions

## Installation & Setup

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd group_two_chatting_app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**:
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication and Firestore Database
   - Add your app to Firebase (Android/iOS/Web as needed)
   - Download and place `google-services.json` (Android) or configure accordingly
   - Update `lib/firebase_options.dart` with your Firebase configuration

4. **Configure Firebase Security Rules**:
   Update your Firestore rules to allow authenticated users to read/write their data.

5. **Run the app**:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point and theme management
├── firebase_options.dart     # Firebase configuration
├── models/
│   ├── user_model.dart       # User data model
│   └── message_model.dart    # Message data model
├── screens/
│   ├── login_screen.dart     # User login interface
│   ├── register_screen.dart  # User registration interface
│   ├── chat_list_screen.dart # List of chat conversations
│   ├── chat_room_screen.dart # Individual chat interface
│   └── settings_screen.dart  # App settings and preferences
└── services/
    ├── auth_service.dart     # Authentication logic
    └── database_service.dart # Firestore database operations
```

## Usage

1. **Registration/Login**: Create an account or log in with existing credentials
2. **Start a Chat**: Tap the "+" button to create a new chat with a friend
3. **Send Messages**: Type and send messages in real-time
4. **Settings**: Access app settings to toggle dark mode and other preferences

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
