<script setup lang="ts">
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
</script>

<template>
  <v-card>
    <v-card-title class="text-h5">
      <v-icon start icon="mdi-format-list-bulleted"></v-icon>
      Your Events
    </v-card-title>
    
    <v-card-text>
      <v-list v-if="events.length > 0">
        <v-list-item
          v-for="event in events"
          :key="event.id"
          @click="emit('selectEvent', event)"
          :title="event.title"
          :subtitle="formatDate(event.date)"
          lines="two"
        >
          <template v-slot:prepend>
            <v-chip
              :color="getCategoryColor(event.category)"
              size="small"
              class="text-caption"
              variant="flat"
            >
              {{ event.category }}
            </v-chip>
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
        text="No events found. Add your first memory!"
        variant="tonal"
      ></v-alert>
    </v-card-text>
  </v-card>
</template>