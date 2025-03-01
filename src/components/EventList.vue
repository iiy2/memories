<script setup lang="ts">
import { ref, computed } from 'vue'

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

const props = defineProps<{
  events: Event[],
  eventTypes: EventType[]
}>()

const emit = defineEmits<{
  (e: 'selectEvent', event: Event): void
  (e: 'deleteEvent', id: string): void
}>()

const search = ref('')
const filterCategory = ref('All')

// Generate category filter options
const categories = computed(() => {
  return ['All', ...props.eventTypes.filter(et => et.enabled).map(et => et.name)]
})

const filteredEvents = computed(() => {
  return props.events
    .filter(event => {
      // Filter by search term
      if (search.value && !event.title.toLowerCase().includes(search.value.toLowerCase()) && 
          !event.description.toLowerCase().includes(search.value.toLowerCase())) {
        return false
      }
      
      // Filter by category
      if (filterCategory.value && filterCategory.value !== 'All' && event.category !== filterCategory.value) {
        return false
      }
      
      return true
    })
    // Sort by date, most recent first
    .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
})

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString()
}

// Get event type by category name
function getEventType(category: string): EventType | undefined {
  return props.eventTypes.find(et => et.name === category)
}

// Get color for category
function getCategoryColor(category: string): string {
  const eventType = getEventType(category)
  return eventType ? eventType.color : 'primary'
}

// Get icon for category
function getCategoryIcon(category: string): string {
  const eventType = getEventType(category)
  return eventType ? eventType.icon : 'mdi-calendar'
}
</script>

<template>
  <v-card elevation="1" class="mx-auto" width="100%">
    <v-card-title class="d-flex align-center">
      <v-icon start icon="mdi-format-list-bulleted" class="mr-2"></v-icon>
      <span class="text-h5">Your Life Events</span>
      <v-spacer></v-spacer>
    </v-card-title>
    
    <v-card-text>
      <v-row>
        <v-col cols="12" sm="6" md="8">
          <v-text-field
            v-model="search"
            clearable
            hide-details
            label="Search events"
            prepend-inner-icon="mdi-magnify"
            density="comfortable"
            variant="outlined"
            single-line
          ></v-text-field>
        </v-col>
        <v-col cols="12" sm="6" md="4">
          <v-select
            v-model="filterCategory"
            :items="categories"
            label="Category"
            density="comfortable"
            hide-details
            variant="outlined"
            single-line
          >
            <template v-slot:selection="{ item }">
              <template v-if="item.raw !== 'All' && getEventType(item.raw)">
                <v-icon :icon="getCategoryIcon(item.raw)" :color="getCategoryColor(item.raw)" class="mr-2"></v-icon>
                {{ item.raw }}
              </template>
              <template v-else>
                <v-icon icon="mdi-filter-variant" class="mr-2"></v-icon>
                {{ item.raw }}
              </template>
            </template>
            <template v-slot:item="{ item, props }">
              <v-list-item v-bind="props">
                <template v-slot:prepend>
                  <template v-if="item.raw !== 'All' && getEventType(item.raw)">
                    <v-icon :icon="getCategoryIcon(item.raw)" :color="getCategoryColor(item.raw)"></v-icon>
                  </template>
                  <template v-else>
                    <v-icon icon="mdi-filter-variant"></v-icon>
                  </template>
                </template>
                <v-list-item-title>{{ item.raw }}</v-list-item-title>
              </v-list-item>
            </template>
          </v-select>
        </v-col>
      </v-row>
    </v-card-text>
    
    <v-divider></v-divider>
    
    <v-card-text class="pa-0">
      <v-list v-if="filteredEvents.length > 0" lines="two">
        <v-list-item
          v-for="event in filteredEvents"
          :key="event.id"
          @click="emit('selectEvent', event)"
          :title="event.title"
          :subtitle="formatDate(event.date)"
          class="event-item"
        >
          <template v-slot:prepend>
            <v-avatar size="48" :color="getCategoryColor(event.category)" class="mr-4">
              <v-icon :icon="getCategoryIcon(event.category)" color="white"></v-icon>
            </v-avatar>
          </template>
          
          <template v-slot:append>
            <v-btn
              icon="mdi-delete"
              variant="text"
              color="error"
              density="compact"
              @click.stop="emit('deleteEvent', event.id)"
            ></v-btn>
          </template>
        </v-list-item>
      </v-list>
      
      <v-alert
        v-else
        type="info"
        class="ma-4"
        text="No events found. Click the + button to add your first memory!"
        variant="tonal"
      ></v-alert>
    </v-card-text>
  </v-card>
</template>

<style scoped>
.event-item {
  transition: background-color 0.2s ease;
  cursor: pointer;
}
.event-item:hover {
  background-color: rgba(0, 0, 0, 0.03);
}
</style>