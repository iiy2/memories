<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue'
import EventForm from './components/EventForm.vue'
import EventList from './components/EventList.vue'
import EventDetail from './components/EventDetail.vue'
import EventSettings from './components/EventSettings.vue'
import PwaNotification from './components/PwaNotification.vue'
import AuthContainer from './components/auth/AuthContainer.vue'
import UserProfile from './components/auth/UserProfile.vue'

// Import stores
import { useAuthStore } from './stores/auth'
import { useEventStore } from './stores/events'
import { useEventTypeStore } from './stores/eventTypes'
import { EventType } from './stores/eventTypes'
import { Event } from './stores/events'

// Initialize stores
const authStore = useAuthStore()
const eventStore = useEventStore()
const eventTypeStore = useEventTypeStore()

// UI state
const selectedEvent = ref<Event | null>(null)
const showEventForm = ref(false)
const showEventDetail = ref(false)
const showDeleteDialog = ref(false)
const showSettingsDialog = ref(false)
const eventToDelete = ref<string | null>(null)

// Set up auth listener and initialize data on mount
onMounted(() => {
  // If user is already authenticated, fetch data
  if (authStore.isAuthenticated) {
    initializeData()
  }
  
  // Listen for auth state changes
  watch(() => authStore.isAuthenticated, (isAuthenticated) => {
    if (isAuthenticated) {
      initializeData()
    } else {
      // Clean up when user logs out
      eventStore.unsubscribeFromEvents()
      eventTypeStore.unsubscribeFromEventTypes()
    }
  })
})

// Initialize data (subscribe to Firestore collections)
function initializeData() {
  // Subscribe to real-time updates
  eventStore.subscribeToEvents()
  eventTypeStore.subscribeToEventTypes()
}

// Event name for deletion confirmation
const eventToDeleteName = computed(() => {
  if (!eventToDelete.value) return ''
  const event = eventStore.events.find(e => e.id === eventToDelete.value)
  return event ? event.title : ''
})

// Add a new event
async function addEvent(event: Omit<Event, 'id'>) {
  try {
    await eventStore.addEvent(event)
    showEventForm.value = false
  } catch (error) {
    console.error('Error adding event:', error)
  }
}

// Delete event confirmation
function confirmDeleteEvent(id: string) {
  eventToDelete.value = id
  showDeleteDialog.value = true
}

// Execute event deletion
async function executeDeleteEvent() {
  if (!eventToDelete.value) return
  
  try {
    await eventStore.deleteEvent(eventToDelete.value)
    
    // Close detail view if the deleted event was selected
    if (selectedEvent.value?.id === eventToDelete.value) {
      selectedEvent.value = null
      showEventDetail.value = false
    }
  } catch (error) {
    console.error('Error deleting event:', error)
  } finally {
    showDeleteDialog.value = false
    eventToDelete.value = null
  }
}

// Cancel event deletion
function cancelDeleteEvent() {
  showDeleteDialog.value = false
  eventToDelete.value = null
}

// Select an event to view details
function selectEvent(event: Event) {
  selectedEvent.value = event
  showEventDetail.value = true
}

// Close event detail dialog
function closeEventDetail() {
  showEventDetail.value = false
  selectedEvent.value = null
}

// Close event form dialog
function closeEventForm() {
  showEventForm.value = false
}

// Toggle settings dialog
function toggleSettingsDialog() {
  showSettingsDialog.value = !showSettingsDialog.value
}

// Add a new event type
async function addEventType(eventType: Omit<EventType, 'id'>) {
  try {
    await eventTypeStore.addEventType(eventType)
  } catch (error) {
    console.error('Error adding event type:', error)
  }
}

// Update an existing event type
async function updateEventType(eventType: EventType) {
  try {
    await eventTypeStore.updateEventType(eventType.id, {
      name: eventType.name,
      color: eventType.color,
      icon: eventType.icon,
      enabled: eventType.enabled
    })
  } catch (error) {
    console.error('Error updating event type:', error)
  }
}

// Remove an event type
async function removeEventType(id: string) {
  try {
    await eventTypeStore.deleteEventType(id)
  } catch (error) {
    console.error('Error removing event type:', error)
  }
}

// Toggle event type enabled status
async function toggleEventType(id: string) {
  try {
    await eventTypeStore.toggleEventType(id)
  } catch (error) {
    console.error('Error toggling event type:', error)
  }
}

// Handle logout
function handleLogout() {
  // Cleanup any references
  selectedEvent.value = null
  showEventForm.value = false
  showEventDetail.value = false
  showSettingsDialog.value = false
}
</script>

<template>
  <!-- Show auth container when not authenticated -->
  <AuthContainer 
    v-if="!authStore.isAuthenticated"
    @auth-success="initializeData"
  />
  
  <!-- Show main application when authenticated -->
  <v-app v-else>
    <v-app-bar color="primary" dark app>
      <v-app-bar-title>Memory AI - Your Life Events</v-app-bar-title>
      <v-spacer></v-spacer>
      <v-btn
        icon
        @click="showEventForm = true"
        title="Add new event"
      >
        <v-icon>mdi-plus</v-icon>
      </v-btn>
      <v-btn
        icon
        @click="toggleSettingsDialog"
        title="Settings"
        class="ml-2"
      >
        <v-icon>mdi-cog</v-icon>
      </v-btn>
      <UserProfile 
        class="ml-2"
        @logout="handleLogout"
      />
    </v-app-bar>

    <v-main>
      <v-container fluid class="pa-0 pa-sm-2 pa-md-4">
        <!-- Loading indicator -->
        <v-progress-linear
          v-if="eventStore.loading || eventTypeStore.loading"
          indeterminate
          color="primary"
        ></v-progress-linear>
        
        <!-- Main Events List -->
        <EventList 
          :events="eventStore.events"
          :event-types="eventTypeStore.eventTypes"
          @select-event="selectEvent" 
          @delete-event="confirmDeleteEvent" 
          class="mx-auto"
        />
      </v-container>
    </v-main>

    <!-- Event Form Dialog -->
    <v-dialog
      v-model="showEventForm"
      max-width="800px"
      width="100%"
    >
      <v-card>
        <v-card-title class="text-h5">
          <v-icon start icon="mdi-calendar-plus" class="mr-2"></v-icon>
          Add New Event
          <v-spacer></v-spacer>
          <v-btn icon @click="closeEventForm">
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </v-card-title>
        <v-card-text>
          <EventForm 
            @add-event="addEvent"
            :event-types="eventTypeStore.enabledEventTypes"
          />
        </v-card-text>
      </v-card>
    </v-dialog>

    <!-- Event Detail Dialog -->
    <v-dialog
      v-model="showEventDetail"
      max-width="1000px"
      width="100%"
    >
      <v-card v-if="selectedEvent">
        <v-card-title class="text-h5">
          Event Details
          <v-spacer></v-spacer>
          <v-btn icon @click="closeEventDetail">
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </v-card-title>
        <v-card-text>
          <EventDetail 
            :event="selectedEvent"
            :event-types="eventTypeStore.eventTypes"
          />
        </v-card-text>
      </v-card>
    </v-dialog>
    
    <!-- Delete Confirmation Dialog -->
    <v-dialog
      v-model="showDeleteDialog"
      max-width="400px"
    >
      <v-card>
        <v-card-title class="text-h5">
          <v-icon icon="mdi-alert" color="error" class="mr-2"></v-icon>
          Confirm Deletion
        </v-card-title>
        <v-card-text>
          Are you sure you want to delete the event "{{ eventToDeleteName }}"? This action cannot be undone.
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="grey-darken-1" variant="text" @click="cancelDeleteEvent">
            Cancel
          </v-btn>
          <v-btn color="error" variant="flat" @click="executeDeleteEvent">
            Delete
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Settings Dialog -->
    <v-dialog
      v-model="showSettingsDialog"
      max-width="1200px"
      width="100%"
    >
      <v-card>
        <v-card-title class="text-h5">
          <v-icon start icon="mdi-cog" class="mr-2"></v-icon>
          Settings
          <v-spacer></v-spacer>
          <v-btn icon @click="showSettingsDialog = false">
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </v-card-title>
        <v-card-text>
          <EventSettings 
            :event-types="eventTypeStore.eventTypes"
            @add-event-type="addEventType"
            @update-event-type="updateEventType"
            @remove-event-type="removeEventType"
            @toggle-event-type="toggleEventType"
          />
        </v-card-text>
      </v-card>
    </v-dialog>

    <v-footer app>
      <div class="mx-auto">
        &copy; {{ new Date().getFullYear() }} - Memory AI
      </div>
    </v-footer>
    
    <!-- PWA notifications -->
    <PwaNotification />
  </v-app>
</template>
