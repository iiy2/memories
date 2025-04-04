# CLAUDE.md - Guidelines for Memory AI Project

## Project Structure
The Memory AI project is a monorepo with the following structure:
- `memory-vue/` - Vue.js web application
- `memory_flutter/` - Flutter mobile application
- `shared/` - Shared resources (Firebase rules, etc.)

## Build & Test Commands

### Root Commands
- Project setup: `npm install`

### Vue App Commands
- Install: `cd memory-vue && npm install`
- Start development server: `npm run vue:dev`
- Build: `npm run vue:build`
- Lint: `cd memory-vue && npm run lint`
- Format: `cd memory-vue && npm run format`

### Flutter App Commands
- Install Flutter dependencies: `cd memory_flutter && flutter pub get`
- Run Flutter app: `npm run flutter:run`
- Build Android APK: `npm run flutter:build-android`
- Build iOS: `npm run flutter:build-ios`

### Firebase Commands
- Deploy Firestore rules: `npm run deploy:rules`

## Code Style Guidelines

### Vue App
- **Formatting**: Follow ESLint & Prettier configs
- **Naming**: camelCase for variables/functions, PascalCase for classes/components
- **Imports**: Group imports (external, internal, relative) with blank line between
- **Types**: Use TypeScript interfaces/types for all components and functions
- **Error Handling**: Use try/catch with specific error types
- **Components**: One component per file, use Composition API with setup script
- **State Management**: Use Pinia for global state
- **Comments**: JSDoc for public APIs, inline for complex logic only

### Flutter App
- **Formatting**: Follow Dart standard formatting
- **Naming**: camelCase for variables/functions, PascalCase for classes/widgets
- **Types**: Use strong typing for all classes and functions
- **Error Handling**: Use try/catch with specific error types
- **Widgets**: One widget per file when possible
- **State Management**: Use Provider for state management
- **Comments**: Dartdoc for public APIs, inline for complex logic only