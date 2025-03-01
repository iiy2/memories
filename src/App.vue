<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import EventForm from './components/EventForm.vue'
import EventList from './components/EventList.vue'
import EventDetail from './components/EventDetail.vue'

interface Event {
  id: string;
  title: string;
  date: string;
  description: string;
  category: string;
}

const events = ref<Event[]>([])
const selectedEvent = ref<Event | null>(null)
const showEventForm = ref(false)
const showEventDetail = ref(false)
const showDeleteDialog = ref(false)
const eventToDelete = ref<string | null>(null)

// Load events from localStorage on component mount
onMounted(() => {
  const savedEvents = localStorage.getItem('memoryEvents')
  if (savedEvents) {
    events.value = JSON.parse(savedEvents)
  }
})

// Save events to localStorage whenever they change
function saveEvents() {
  localStorage.setItem('memoryEvents', JSON.stringify(events.value))
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
</script>

<template>
  <v-app>
    <v-app-bar color="primary" dark app>
      <v-app-bar-title>Memory AI - Your Life Events</v-app-bar-title>
      <v-spacer></v-spacer>
      <v-btn
        icon
        @click="showEventForm = true"
      >
        <v-icon>mdi-plus</v-icon>
      </v-btn>
    </v-app-bar>

    <v-main>
      <v-container fluid>
        <!-- Main Events List -->
        <EventList 
          :events="events" 
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
          <EventForm @add-event="addEvent" />
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
          <EventDetail :event="selectedEvent" />
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
  </v-app>
</template>
