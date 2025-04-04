# Memory AI - Flutter App

Memory AI is a modern Flutter application that helps you track and organize your important life events. This app is the Flutter version of the original Vue-based Memory AI web application.

## Features

- User authentication (login, register, logout)
- Create, view, and delete life events
- Categorize events with customizable event types
- Filter events by category and search by text
- Customize event categories with colors and icons
- Real-time data synchronization with Firestore

## Technologies Used

- Flutter (UI framework)
- Firebase Authentication (user management)
- Cloud Firestore (database)
- Provider (state management)

## Setup Instructions

### Prerequisites

- Flutter SDK (latest stable version)
- Firebase account
- Android Studio or VS Code with Flutter extensions

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/your-username/memory-flutter.git
   cd memory-flutter
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Create a Firebase project and configure Firebase:
   - Create a new project in the Firebase Console
   - Enable Authentication (Email/Password)
   - Create a Firestore database
   - Add your app to Firebase (Android/iOS)
   - Download the configuration files (google-services.json for Android, GoogleService-Info.plist for iOS)
   - Place the configuration files in their respective platform folders

4. Run the app:
   ```
   flutter run
   ```

## Project Structure

```
lib/
  ├── models/               # Data models
  │   ├── event.dart        # Event data model
  │   ├── event_type.dart   # Event type data model
  │   └── user_model.dart   # User data model
  │
  ├── providers/            # State management
  │   ├── auth_provider.dart      # User authentication state
  │   ├── event_provider.dart     # Events state management
  │   └── event_type_provider.dart # Event types state management
  │
  ├── screens/              # App screens
  │   ├── event_detail_screen.dart # Event details view
  │   ├── event_form_screen.dart   # Add/edit event screen
  │   ├── home_screen.dart        # Main screen with events list
  │   ├── login_screen.dart       # Authentication screen
  │   ├── settings_screen.dart    # Settings/preferences screen
  │   └── splash_screen.dart      # Loading screen
  │
  ├── services/             # Firebase services
  │   ├── auth_service.dart       # Authentication service
  │   └── firestore_service.dart  # Database service
  │
  ├── utils/                # Utility functions
  │   ├── date_utils.dart         # Date formatting utilities
  │   └── validators.dart         # Input validation utilities
  │
  ├── widgets/              # Reusable UI components
  │   ├── category_filter.dart    # Category filtering component
  │   ├── event_card.dart         # Event list item component
  │   └── search_bar.dart         # Search component
  │
  └── main.dart             # App entry point
```

## Firebase Security Rules

For proper security, implement these Firestore security rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /events/{eventId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }
    
    match /eventTypes/{typeId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }
  }
}
```

## License

This project is licensed under the MIT License.