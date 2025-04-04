<script setup lang="ts">
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
  event: Event | null,
  eventTypes: EventType[]
}>()

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

function formatTime(dateString: string) {
  const date = new Date(dateString)
  const now = new Date()
  
  // If the event is from today
  if (date.toDateString() === now.toDateString()) {
    return 'Today'
  }
  
  // If the event was yesterday
  const yesterday = new Date(now)
  yesterday.setDate(now.getDate() - 1)
  if (date.toDateString() === yesterday.toDateString()) {
    return 'Yesterday'
  }
  
  // Calculate days ago for recent events (within 7 days)
  const diffTime = Math.abs(now.getTime() - date.getTime())
  const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24))
  
  if (diffDays < 7) {
    return `${diffDays} days ago`
  }
  
  // For older events, return the month and day
  return date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric'
  })
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
  <div v-if="event">
    <div class="d-flex align-center mb-6">
      <v-avatar :color="getCategoryColor(event.category)" size="60" class="mr-4">
        <v-icon :icon="getCategoryIcon(event.category)" size="large" color="white"></v-icon>
      </v-avatar>
      
      <div>
        <h1 class="text-h4 mb-1">{{ event.title }}</h1>
        <div class="d-flex align-center">
          <v-chip
            :color="getCategoryColor(event.category)"
            class="mr-3"
            size="small"
            variant="flat"
          >
            {{ event.category }}
          </v-chip>
          <div class="text-subtitle-1">
            <v-icon icon="mdi-calendar" size="small" class="mr-1"></v-icon>
            {{ formatDate(event.date) }}
            <span class="text-caption ml-1 text-grey">({{ formatTime(event.date) }})</span>
          </div>
        </div>
      </div>
    </div>
    
    <v-divider class="mb-6"></v-divider>
    
    <div class="event-description">
      <h2 class="text-h6 mb-3">Description</h2>
      <v-card elevation="0" variant="outlined" class="pa-4 bg-grey-lighten-5">
        <div class="text-body-1 text-pre-wrap">
          {{ event.description || 'No description provided.' }}
        </div>
      </v-card>
    </div>
  </div>
  
  <div v-else class="d-flex align-center justify-center" style="height: 300px">
    <div class="text-center">
      <v-icon icon="mdi-calendar-blank" size="x-large" color="grey" class="mb-4"></v-icon>
      <h3 class="text-h5 text-grey">Select an event to view details</h3>
    </div>
  </div>
</template>

<style scoped>
.text-pre-wrap {
  white-space: pre-wrap;
  min-height: 100px;
  line-height: 1.6;
}

.event-description {
  margin-bottom: 24px;
}

/* Print styles for when user wants to print an event */
@media print {
  .event-description {
    break-inside: avoid;
  }
  
  .text-pre-wrap {
    white-space: pre-wrap;
    line-height: 1.5;
  }
}
</style>