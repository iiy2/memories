# Memory AI - Vue Web App

This is the Vue.js web application for Memory AI, a life events tracker that helps you organize and remember important moments.

## Features

- User authentication (login, register, logout)
- Create, view, and delete life events
- Categorize events with customizable event types
- Filter events by category and search by text
- Customize event categories with colors and icons
- Real-time data synchronization with Firestore

## Technologies Used

- Vue 3 (Composition API)
- Vuetify 3 (Material Design components)
- Pinia (State management)
- Firebase Authentication
- Cloud Firestore
- TypeScript
- Vite (Build tool)

## Setup Instructions

### Prerequisites

- Node.js (v16+)
- npm or yarn
- Firebase account

### Installation

1. Clone the repository and navigate to the Vue app directory:
   ```
   git clone https://github.com/your-username/memory-ai.git
   cd memory-ai/memory-vue
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Create a Firebase project and configure Firebase:
   - Create a new project in the Firebase Console
   - Enable Authentication (Email/Password)
   - Create a Firestore database
   - Set up Firebase hosting (optional)
   - Add a Web app to your Firebase project

4. Create a `.env` file in the root directory with your Firebase configuration:
   ```
   VITE_FIREBASE_API_KEY=your-api-key
   VITE_FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
   VITE_FIREBASE_PROJECT_ID=your-project-id
   VITE_FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
   VITE_FIREBASE_MESSAGING_SENDER_ID=your-messaging-sender-id
   VITE_FIREBASE_APP_ID=your-app-id
   ```

5. Start the development server:
   ```
   npm run dev
   ```

6. Build for production:
   ```
   npm run build
   ```

## Project Structure

```
src/
  ├── components/       # UI components
  │   ├── EventDetail.vue
  │   ├── EventForm.vue
  │   ├── EventList.vue
  │   └── EventSettings.vue
  │
  ├── firebase/         # Firebase configuration and services
  │   ├── auth.ts
  │   ├── config.ts
  │   └── firestore.ts
  │
  ├── stores/           # Pinia stores for state management
  │   ├── auth.ts
  │   ├── events.ts
  │   └── eventTypes.ts
  │
  ├── App.vue           # Root component
  └── main.ts           # Application entry point
```

## Firebase Security Rules

For proper security, implement the Firestore security rules found in the `shared/firestore.rules` file.

## Progressive Web App

This application is configured as a Progressive Web App (PWA) for installation on supported devices.