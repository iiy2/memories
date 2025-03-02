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
  <v-card elevation="1" class="mx-auto" style="max-width: 1400px; width: 100%">
    <v-card-title class="d-flex align-center">
      <v-icon start icon="mdi-format-list-bulleted" class="mr-2"></v-icon>
      <span class="text-h5">Your Life Events</span>
      <v-spacer></v-spacer>
    </v-card-title>
    
    <v-card-text>
      <v-row align="center" justify="start">
        <v-col cols="12" sm="6" md="8">
          <v-text-field
            v-model="search"
            clearable
            hide-details
            label="Search events by title, description..."
            prepend-inner-icon="mdi-magnify"
            density="comfortable"
            variant="outlined"
            single-line
            class="search-field"
          ></v-text-field>
        </v-col>
        <v-col cols="12" sm="6" md="4">
          <v-select
            v-model="filterCategory"
            :items="categories"
            label="Filter by Category"
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

      <!-- Show filter summary and count -->
      <div class="d-flex align-center px-1 py-2">
        <span class="text-subtitle-2">
          <strong>{{ filteredEvents.length }}</strong> 
          {{ filteredEvents.length === 1 ? 'event' : 'events' }} found
          <template v-if="filterCategory && filterCategory !== 'All'">
            in <v-chip size="x-small" :color="getCategoryColor(filterCategory)" class="ml-1">{{ filterCategory }}</v-chip>
          </template>
          <template v-if="search">
            <span class="ml-1">matching "<strong>{{ search }}</strong>"</span>
          </template>
        </span>
        <v-spacer></v-spacer>
        <v-btn 
          v-if="search || (filterCategory && filterCategory !== 'All')"
          size="small" 
          variant="text" 
          color="primary"
          @click="() => { search = ''; filterCategory = 'All'; }"
        >
          <v-icon start>mdi-filter-remove</v-icon>
          Clear filters
        </v-btn>
      </div>
    </v-card-text>
    
    <v-divider></v-divider>
    
    <v-card-text class="pa-4">
      <div v-if="filteredEvents.length > 0">
        <v-row>
          <v-col 
            v-for="event in filteredEvents" 
            :key="event.id"
            cols="12" sm="6" md="4" lg="3"
            class="pa-2"
          >
            <v-card
              elevation="2"
              hover
              @click="emit('selectEvent', event)"
              class="event-card h-100"
            >
              <v-card-item>
                <template v-slot:prepend>
                  <v-avatar :color="getCategoryColor(event.category)" size="42">
                    <v-icon :icon="getCategoryIcon(event.category)" color="white"></v-icon>
                  </v-avatar>
                </template>
                <v-card-title class="text-truncate">{{ event.title }}</v-card-title>
                <template v-slot:append>
                  <v-btn
                    icon="mdi-delete"
                    variant="text"
                    color="error"
                    density="compact"
                    @click.stop="emit('deleteEvent', event.id)"
                  ></v-btn>
                </template>
              </v-card-item>
              
              <v-card-text class="pb-0">
                <v-chip
                  size="small"
                  :color="getCategoryColor(event.category)"
                  variant="flat"
                  class="mb-2"
                >
                  {{ event.category }}
                </v-chip>
                <div class="text-body-2 text-medium-emphasis mt-1">
                  <v-icon icon="mdi-calendar" size="small" class="mr-1"></v-icon>
                  {{ formatDate(event.date) }}
                </div>
                <div v-if="event.description" class="text-body-2 mt-2 text-truncate-3-lines">
                  {{ event.description }}
                </div>
              </v-card-text>
              
              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn
                  variant="text"
                  color="primary"
                  size="small"
                  @click.stop="emit('selectEvent', event)"
                >
                  View Details
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-col>
        </v-row>
      </div>
      
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
.event-card {
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  cursor: pointer;
  overflow: hidden;
}

.event-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15) !important;
}

.text-truncate {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 100%;
}

.text-truncate-3-lines {
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>