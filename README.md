# Memory AI - Life Events Tracker

A Progressive Web App (PWA) for storing and tracking important events from your life. Built with Vue 3, TypeScript, and Vuetify (Material UI).

## Features

- Create and store life events with title, date, category, and description
- View events in a categorized list
- See detailed information about each event
- Delete events you no longer want to track
- Data persists in local storage
- **Progressive Web App (PWA) Features:**
  - Installable on desktop and mobile devices
  - Works offline
  - Fast load times
  - Automatic updates
  - Responsive design for all screen sizes

## Categories

- Personal
- Work
- Family
- Health
- Travel
- Other

## Getting Started

### Prerequisites

- Node.js (version 16 or higher)
- npm or yarn

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd memory-ai
```

2. Install dependencies:
```bash
npm install
```

3. Start the development server:
```bash
npm run dev
```

4. Open your browser and navigate to `http://localhost:5173`

### Building for Production

```bash
npm run build
```

This will generate optimized production files in the `dist` directory.

## Tech Stack

- Vue 3 with Composition API
- TypeScript
- Vuetify (Material UI)
- Vite
- localStorage for data persistence
- Progressive Web App (PWA) features using:
  - vite-plugin-pwa
  - Service Workers
  - Web App Manifest

## Project Structure

- `src/App.vue` - Main application component
- `src/components/` - Vue components
  - `EventForm.vue` - Form for adding new events
  - `EventList.vue` - List of all stored events
  - `EventDetail.vue` - Detailed view of a selected event
  - `PwaNotification.vue` - PWA update and offline notifications
- `src/main.ts` - Application entry point with Vuetify and PWA configuration
- `public/` - Static assets and PWA icons
- `vite.config.ts` - Vite configuration including PWA settings

## License

MIT
