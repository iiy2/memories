<script setup lang="ts">
interface Event {
  id: string;
  title: string;
  date: string;
  description: string;
  category: string;
}

const props = defineProps<{
  event: Event | null
}>()

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
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
  <v-card v-if="event" class="h-100">
    <v-card-title class="text-h4 pa-4">
      {{ event.title }}
    </v-card-title>
    
    <v-card-subtitle class="pb-0">
      <v-chip
        :color="getCategoryColor(event.category)"
        class="mr-2"
        size="small"
        variant="flat"
      >
        <v-icon start :icon="getCategoryIcon(event.category)"></v-icon>
        {{ event.category }}
      </v-chip>
      <span class="text-subtitle-1">{{ formatDate(event.date) }}</span>
    </v-card-subtitle>
    
    <v-divider class="mx-4 my-4"></v-divider>
    
    <v-card-text class="text-body-1">
      <div class="text-pre-wrap">{{ event.description || 'No description provided.' }}</div>
    </v-card-text>
  </v-card>
  
  <v-card v-else class="h-100 d-flex align-center justify-center">
    <v-card-text class="text-center">
      <v-icon icon="mdi-calendar-blank" size="x-large" color="grey" class="mb-4"></v-icon>
      <h3 class="text-h5 text-grey">Select an event to view details</h3>
    </v-card-text>
  </v-card>
</template>

<style scoped>
.text-pre-wrap {
  white-space: pre-wrap;
}
</style>