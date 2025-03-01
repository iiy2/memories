<script setup lang="ts">
import { ref, computed } from 'vue'

interface Event {
  id: string;
  title: string;
  date: string;
  description: string;
  category: string;
}

const props = defineProps<{
  events: Event[]
}>()

const emit = defineEmits<{
  (e: 'selectEvent', event: Event): void
  (e: 'deleteEvent', id: string): void
}>()

const search = ref('')
const filterCategory = ref('')

const categories = [
  'All', 'Personal', 'Work', 'Family', 'Health', 'Travel', 'Other'
]

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

// Get color for category
function getCategoryColor(category: string): string {
  const colorMap: Record<string, string> = {
    'Personal': 'blue',
    'Work': 'amber',
    'Family': 'pink',
    'Health': 'green',
    'Travel': 'purple',
    'Other': 'grey'
  }
  
  return colorMap[category] || 'primary'
}

// Get icon for category
function getCategoryIcon(category: string): string {
  const iconMap: Record<string, string> = {
    'Personal': 'mdi-account',
    'Work': 'mdi-briefcase',
    'Family': 'mdi-home-heart',
    'Health': 'mdi-heart-pulse',
    'Travel': 'mdi-airplane',
    'Other': 'mdi-star'
  }
  
  return iconMap[category] || 'mdi-calendar'
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
          ></v-select>
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