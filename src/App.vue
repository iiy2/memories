<script setup lang="ts">
import { ref, onMounted } from 'vue'
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

function addEvent(event: Omit<Event, 'id'>) {
  const newEvent = {
    ...event,
    id: crypto.randomUUID()
  }
  events.value.push(newEvent)
  saveEvents()
}

function deleteEvent(id: string) {
  events.value = events.value.filter(event => event.id !== id)
  if (selectedEvent.value?.id === id) {
    selectedEvent.value = null
  }
  saveEvents()
}

function selectEvent(event: Event) {
  selectedEvent.value = event
}
</script>

<template>
  <v-app>
    <v-app-bar color="primary" dark app>
      <v-app-bar-title>Memory AI - Your Life Events</v-app-bar-title>
    </v-app-bar>

    <v-main>
      <v-container fluid>
        <v-row>
          <v-col cols="12" md="4">
            <EventForm @add-event="addEvent" />
            <v-divider class="my-4"></v-divider>
            <EventList 
              :events="events" 
              @select-event="selectEvent" 
              @delete-event="deleteEvent" 
            />
          </v-col>
          <v-col cols="12" md="8">
            <EventDetail :event="selectedEvent" />
          </v-col>
        </v-row>
      </v-container>
    </v-main>

    <v-footer app>
      <div class="mx-auto">
        &copy; {{ new Date().getFullYear() }} - Memory AI
      </div>
    </v-footer>
  </v-app>
</template>
