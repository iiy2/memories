# Memory AI - Life Events Tracker

Memory AI is a comprehensive application that helps you track and organize your important life events. This project includes both web (Vue) and mobile (Flutter) applications that share the same backend infrastructure.

## Project Structure

The repository is organized as follows:

```
memory-ai/
├── memory-vue/       # Vue.js web application
├── memory_flutter/   # Flutter mobile application
└── shared/           # Shared resources (Firebase rules, etc.)
```

## Applications

### Vue Web App

The Vue.js application provides a web interface for the Memory AI service.

- **Tech Stack**: Vue 3, Vuetify, Firebase Authentication, Firestore
- **Setup**: See [memory-vue/README.md](memory-vue/README.md) for instructions

### Flutter Mobile App

The Flutter application provides a native mobile experience for iOS and Android.

- **Tech Stack**: Flutter, Provider, Firebase Authentication, Firestore
- **Setup**: See [memory_flutter/README.md](memory_flutter/README.md) for instructions

## Shared Resources

The `shared` directory contains resources that are common to both applications, such as:

- Firebase security rules
- API schema definitions
- Shared documentation

## Features

Both applications provide the following features:

- User authentication (login, register, logout)
- Create, view, and delete life events
- Categorize events with customizable event types
- Filter events by category and search by text
- Customize event categories with colors and icons
- Real-time data synchronization with Firestore

## Development

To work on both applications side by side:

1. Set up the Vue application
2. Set up the Flutter application
3. Use the same Firebase project for both to share authentication and database

## License

This project is licensed under the MIT License.