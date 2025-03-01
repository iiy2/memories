<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import EventForm from './components/EventForm.vue'
import EventList from './components/EventList.vue'
import EventDetail from './components/EventDetail.vue'
import EventSettings from './components/EventSettings.vue'
import PwaNotification from './components/PwaNotification.vue'

interface EventType {
  id: string;
  name: string;
  color: string;
  icon: string;
  enabled: boolean;
}

interface Event {
  id: string;
  title: string;
  date: string;
  description: string;
  category: string;
}

const events = ref<Event[]>([])
const eventTypes = ref<EventType[]>([
  { id: 'personal', name: 'Personal', color: 'blue', icon: 'mdi-account', enabled: true },
  { id: 'work', name: 'Work', color: 'amber', icon: 'mdi-briefcase', enabled: true },
  { id: 'family', name: 'Family', color: 'pink', icon: 'mdi-home-heart', enabled: true },
  { id: 'health', name: 'Health', color: 'green', icon: 'mdi-heart-pulse', enabled: true },
  { id: 'travel', name: 'Travel', color: 'purple', icon: 'mdi-airplane', enabled: true },
  { id: 'other', name: 'Other', color: 'grey', icon: 'mdi-star', enabled: true }
])
const selectedEvent = ref<Event | null>(null)
const showEventForm = ref(false)
const showEventDetail = ref(false)
const showDeleteDialog = ref(false)
const showSettingsDialog = ref(false)
const eventToDelete = ref<string | null>(null)

// Load events and event types from localStorage on component mount
onMounted(() => {
  const savedEvents = localStorage.getItem('memoryEvents')
  if (savedEvents) {
    events.value = JSON.parse(savedEvents)
  }
  
  const savedEventTypes = localStorage.getItem('memoryEventTypes')
  if (savedEventTypes) {
    eventTypes.value = JSON.parse(savedEventTypes)
  }
})

// Save events to localStorage whenever they change
function saveEvents() {
  localStorage.setItem('memoryEvents', JSON.stringify(events.value))
}

// Save event types to localStorage whenever they change
function saveEventTypes() {
  localStorage.setItem('memoryEventTypes', JSON.stringify(eventTypes.value))
}

// Get event name by ID
const eventToDeleteName = computed(() => {
  if (!eventToDelete.value) return ''
  const event = events.value.find(e => e.id === eventToDelete.value)
  return event ? event.title : ''
})

function addEvent(event: Omit<Event, 'id'>) {
  const newEvent = {
    ...event,
    id: crypto.randomUUID()
  }
  events.value.push(newEvent)
  saveEvents()
  showEventForm.value = false
}

function confirmDeleteEvent(id: string) {
  eventToDelete.value = id
  showDeleteDialog.value = true
}

function executeDeleteEvent() {
  if (!eventToDelete.value) return
  
  events.value = events.value.filter(event => event.id !== eventToDelete.value)
  if (selectedEvent.value?.id === eventToDelete.value) {
    selectedEvent.value = null
    showEventDetail.value = false
  }
  saveEvents()
  showDeleteDialog.value = false
  eventToDelete.value = null
}

function cancelDeleteEvent() {
  showDeleteDialog.value = false
  eventToDelete.value = null
}

function selectEvent(event: Event) {
  selectedEvent.value = event
  showEventDetail.value = true
}

function closeEventDetail() {
  showEventDetail.value = false
  selectedEvent.value = null
}

function closeEventForm() {
  showEventForm.value = false
}

function toggleSettingsDialog() {
  showSettingsDialog.value = !showSettingsDialog.value
}

function addEventType(eventType: Omit<EventType, 'id'>) {
  const id = eventType.name.toLowerCase().replace(/\s+/g, '-')
  const newEventType = {
    ...eventType,
    id
  }
  
  // Check if the event type already exists
  const existingType = eventTypes.value.find(et => et.id === id || et.name === eventType.name)
  if (existingType) {
    // If it exists but is disabled, just enable it
    if (!existingType.enabled) {
      existingType.enabled = true
      existingType.color = eventType.color
      existingType.icon = eventType.icon
      saveEventTypes()
    }
    return
  }
  
  eventTypes.value.push(newEventType)
  saveEventTypes()
}

function updateEventType(eventType: EventType) {
  const index = eventTypes.value.findIndex(et => et.id === eventType.id)
  if (index !== -1) {
    eventTypes.value[index] = eventType
    saveEventTypes()
  }
}

function removeEventType(id: string) {
  // Check if there are any events with this category
  const hasEvents = events.value.some(event => event.category.toLowerCase() === id)
  
  if (hasEvents) {
    // If events exist with this category, just disable it instead of removing
    const eventType = eventTypes.value.find(et => et.id === id)
    if (eventType) {
      eventType.enabled = false
      saveEventTypes()
    }
  } else {
    // If no events use this category, we can remove it completely
    eventTypes.value = eventTypes.value.filter(et => et.id !== id)
    saveEventTypes()
  }
}

function toggleEventType(id: string) {
  const eventType = eventTypes.value.find(et => et.id === id)
  if (eventType) {
    eventType.enabled = !eventType.enabled
    saveEventTypes()
  }
}
</script>

<template>
  <v-app>
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
    </v-app-bar>

    <v-main>
      <v-container fluid>
        <!-- Main Events List -->
        <EventList 
          :events="events"
          :event-types="eventTypes"
          @select-event="selectEvent" 
          @delete-event="confirmDeleteEvent" 
        />
      </v-container>
    </v-main>

    <!-- Event Form Dialog -->
    <v-dialog
      v-model="showEventForm"
      max-width="600px"
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
            :event-types="eventTypes.filter(et => et.enabled)"
          />
        </v-card-text>
      </v-card>
    </v-dialog>

    <!-- Event Detail Dialog -->
    <v-dialog
      v-model="showEventDetail"
      max-width="800px"
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
            :event-types="eventTypes"
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

    <v-footer app>
      <div class="mx-auto">
        &copy; {{ new Date().getFullYear() }} - Memory AI
      </div>
    </v-footer>
    
    <!-- Settings Dialog -->
    <v-dialog
      v-model="showSettingsDialog"
      max-width="900px"
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
            :event-types="eventTypes"
            @add-event-type="addEventType"
            @update-event-type="updateEventType"
            @remove-event-type="removeEventType"
            @toggle-event-type="toggleEventType"
          />
        </v-card-text>
      </v-card>
    </v-dialog>

    <!-- PWA notifications -->
    <PwaNotification />
  </v-app>
</template>
