import { createApp } from 'vue'
import { createVuetify } from 'vuetify'
import { createPinia } from 'pinia'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import 'vuetify/styles'
import '@mdi/font/css/materialdesignicons.css'
import './style.css'
import App from './App.vue'
import { registerSW } from 'virtual:pwa-register'

// Register service worker for PWA without storing the update function
// since we're handling updates in the PwaNotification component
registerSW({
  onNeedRefresh() {
    // Show a notification to the user when a new version is available
    console.log('New content available, click on reload button to update.')
  },
  onOfflineReady() {
    // Show a notification to the user when the app is ready for offline usage
    console.log('App ready to work offline')
  },
})

// Create Pinia store
const pinia = createPinia()

// Create Vuetify instance
const vuetify = createVuetify({
  components,
  directives,
  theme: {
    defaultTheme: 'light'
  }
})

createApp(App)
  .use(pinia)
  .use(vuetify)
  .mount('#app')
