<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { registerSW } from 'virtual:pwa-register'

const showRefreshNotification = ref(false)
const showOfflineNotification = ref(false)
const offlineNotificationTimeout = ref<number | null>(null)
// Move updateSW declaration outside of onMounted to make it accessible to all functions
const updateSW = registerSW({
  onNeedRefresh() {
    showRefreshNotification.value = true
  },
  onOfflineReady() {
    showOfflineNotification.value = true
    
    // Hide offline notification after 3 seconds
    if (offlineNotificationTimeout.value) {
      clearTimeout(offlineNotificationTimeout.value)
    }
    
    offlineNotificationTimeout.value = window.setTimeout(() => {
      showOfflineNotification.value = false
    }, 3000)
  },
})

onMounted(() => {
  // Check if we're offline
  if (!navigator.onLine) {
    showOfflineNotification.value = true
  }
  
  // Listen for online/offline events
  window.addEventListener('online', () => {
    showOfflineNotification.value = false
  })
  
  window.addEventListener('offline', () => {
    showOfflineNotification.value = true
  })
})

function refreshApp() {
  // Use the updateSW function to update the service worker
  updateSW(true)
  showRefreshNotification.value = false
}

function closeRefreshNotification() {
  showRefreshNotification.value = false
}

function closeOfflineNotification() {
  showOfflineNotification.value = false
}
</script>

<template>
  <!-- New content notification -->
  <v-snackbar
    v-model="showRefreshNotification"
    :timeout="-1"
    color="info"
    location="top"
  >
    New version available!
    
    <template v-slot:actions>
      <v-btn
        variant="text"
        @click="refreshApp"
      >
        Refresh
      </v-btn>
      <v-btn
        variant="text"
        @click="closeRefreshNotification"
      >
        Dismiss
      </v-btn>
    </template>
  </v-snackbar>
  
  <!-- Offline notification -->
  <v-snackbar
    v-model="showOfflineNotification"
    timeout="3000"
    color="warning"
    location="bottom"
  >
    <v-icon start>mdi-wifi-off</v-icon>
    You're currently offline. The app will continue to work.
    
    <template v-slot:actions>
      <v-btn
        variant="text"
        @click="closeOfflineNotification"
      >
        OK
      </v-btn>
    </template>
  </v-snackbar>
</template>