<script setup lang="ts">
import { ref, computed } from 'vue'

interface EventType {
  id: string;
  name: string;
  color: string;
  icon: string;
  enabled: boolean;
}

const props = defineProps<{
  eventTypes: EventType[]
}>()

const emit = defineEmits<{
  (e: 'addEventType', eventType: Omit<EventType, 'id'>): void
  (e: 'updateEventType', eventType: EventType): void
  (e: 'removeEventType', id: string): void
  (e: 'toggleEventType', id: string): void
}>()

// Available color options
const colorOptions = [
  { name: 'Red', value: 'red' },
  { name: 'Pink', value: 'pink' },
  { name: 'Purple', value: 'purple' },
  { name: 'Deep Purple', value: 'deep-purple' },
  { name: 'Indigo', value: 'indigo' },
  { name: 'Blue', value: 'blue' },
  { name: 'Light Blue', value: 'light-blue' },
  { name: 'Cyan', value: 'cyan' },
  { name: 'Teal', value: 'teal' },
  { name: 'Green', value: 'green' },
  { name: 'Light Green', value: 'light-green' },
  { name: 'Lime', value: 'lime' },
  { name: 'Yellow', value: 'yellow' },
  { name: 'Amber', value: 'amber' },
  { name: 'Orange', value: 'orange' },
  { name: 'Deep Orange', value: 'deep-orange' },
  { name: 'Brown', value: 'brown' },
  { name: 'Grey', value: 'grey' },
  { name: 'Blue Grey', value: 'blue-grey' }
]

// Available icon options
const iconOptions = [
  { name: 'Account', value: 'mdi-account' },
  { name: 'Briefcase', value: 'mdi-briefcase' },
  { name: 'Home', value: 'mdi-home' },
  { name: 'Heart', value: 'mdi-heart' },
  { name: 'Health', value: 'mdi-heart-pulse' },
  { name: 'Family', value: 'mdi-home-heart' },
  { name: 'Travel', value: 'mdi-airplane' },
  { name: 'School', value: 'mdi-school' },
  { name: 'Book', value: 'mdi-book' },
  { name: 'Food', value: 'mdi-food' },
  { name: 'Sports', value: 'mdi-basketball' },
  { name: 'Party', value: 'mdi-party-popper' },
  { name: 'Music', value: 'mdi-music' },
  { name: 'Movie', value: 'mdi-movie' },
  { name: 'Game', value: 'mdi-gamepad-variant' },
  { name: 'Shopping', value: 'mdi-cart' },
  { name: 'Car', value: 'mdi-car' },
  { name: 'Beach', value: 'mdi-beach' },
  { name: 'Hiking', value: 'mdi-hiking' },
  { name: 'Star', value: 'mdi-star' }
]

// New event type form
const newEventType = ref({
  name: '',
  color: 'blue',
  icon: 'mdi-star',
  enabled: true
})

// Form validation
const nameRules = [
  (v: string) => !!v || 'Name is required',
  (v: string) => v.length <= 20 || 'Name must be less than 20 characters',
  (v: string) => /^[a-zA-Z0-9 ]+$/.test(v) || 'Name can only contain letters, numbers, and spaces'
]

// Fix: Change type to accept boolean | null
const formValid = ref<boolean | null>(false)
const editMode = ref(false)
const editingEventTypeId = ref('')

const sortedEventTypes = computed(() => {
  return [...props.eventTypes].sort((a, b) => {
    // Enabled types first, then alphabetical
    if (a.enabled && !b.enabled) return -1
    if (!a.enabled && b.enabled) return 1
    return a.name.localeCompare(b.name)
  })
})

function submitForm() {
  // Fix: Add null check to properly handle the type
  if (!formValid.value) return
  
  if (editMode.value) {
    // Update existing event type
    const eventType = props.eventTypes.find(et => et.id === editingEventTypeId.value)
    if (eventType) {
      emit('updateEventType', {
        ...eventType,
        name: newEventType.value.name,
        color: newEventType.value.color,
        icon: newEventType.value.icon,
        enabled: true
      })
    }
  } else {
    // Add new event type
    emit('addEventType', newEventType.value)
  }
  
  // Reset form
  resetForm()
}

function editEventType(eventType: EventType) {
  editMode.value = true
  editingEventTypeId.value = eventType.id
  newEventType.value = {
    name: eventType.name,
    color: eventType.color,
    icon: eventType.icon,
    enabled: eventType.enabled
  }
}

function resetForm() {
  newEventType.value = {
    name: '',
    color: 'blue',
    icon: 'mdi-star',
    enabled: true
  }
  editMode.value = false
  editingEventTypeId.value = ''
}

function handleRemove(id: string) {
  // If we're editing this event type, cancel the edit
  if (editMode.value && editingEventTypeId.value === id) {
    resetForm()
  }
  
  emit('removeEventType', id)
}

// Function to safely toggle the event type
function handleToggle(eventType: EventType) {
  emit('toggleEventType', eventType.id)
}
</script>

<template>
  <div>
    <v-card class="mb-4">
      <v-card-title class="text-h5">
        <v-icon start>mdi-shape</v-icon>
        {{ editMode ? 'Edit Event Type' : 'Add New Event Type' }}
      </v-card-title>
      
      <v-card-text>
        <v-form v-model="formValid" @submit.prevent="submitForm">
          <v-text-field
            v-model="newEventType.name"
            label="Event Type Name"
            :rules="nameRules"
            required
            variant="outlined"
            density="comfortable"
          ></v-text-field>
          
          <v-row>
            <v-col cols="12" sm="6">
              <v-select
                v-model="newEventType.color"
                label="Color"
                :items="colorOptions"
                item-title="name"
                item-value="value"
                variant="outlined"
                density="comfortable"
              >
                <template v-slot:selection="{ item }">
                  <v-avatar size="24" :color="item.raw.value" class="mr-2"></v-avatar>
                  {{ item.raw.name }}
                </template>
                <template v-slot:item="{ item, props }">
                  <v-list-item v-bind="props">
                    <template v-slot:prepend>
                      <v-avatar size="24" :color="item.raw.value"></v-avatar>
                    </template>
                    <v-list-item-title>{{ item.raw.name }}</v-list-item-title>
                  </v-list-item>
                </template>
              </v-select>
            </v-col>
            
            <v-col cols="12" sm="6">
              <v-select
                v-model="newEventType.icon"
                label="Icon"
                :items="iconOptions"
                item-title="name"
                item-value="value"
                variant="outlined"
                density="comfortable"
              >
                <template v-slot:selection="{ item }">
                  <v-icon :icon="item.raw.value" class="mr-2"></v-icon>
                  {{ item.raw.name }}
                </template>
                <template v-slot:item="{ item, props }">
                  <v-list-item v-bind="props">
                    <template v-slot:prepend>
                      <v-icon :icon="item.raw.value"></v-icon>
                    </template>
                    <v-list-item-title>{{ item.raw.name }}</v-list-item-title>
                  </v-list-item>
                </template>
              </v-select>
            </v-col>
          </v-row>
          
          <div class="d-flex mt-4">
            <v-btn
              color="grey-lighten-1"
              variant="text"
              @click="resetForm"
              class="mr-2"
            >
              {{ editMode ? 'Cancel' : 'Reset' }}
            </v-btn>
            <v-spacer></v-spacer>
            <v-btn
              type="submit"
              color="primary"
              :disabled="!formValid"
            >
              <v-icon start>{{ editMode ? 'mdi-content-save' : 'mdi-plus' }}</v-icon>
              {{ editMode ? 'Update' : 'Add' }} Event Type
            </v-btn>
          </div>
        </v-form>
      </v-card-text>
    </v-card>
    
    <v-card>
      <v-card-title class="text-h5">
        <v-icon start>mdi-format-list-bulleted</v-icon>
        Manage Event Types
      </v-card-title>
      
      <v-card-text>
        <v-list v-if="props.eventTypes.length">
          <v-list-item
            v-for="eventType in sortedEventTypes"
            :key="eventType.id"
          >
            <template v-slot:prepend>
              <v-avatar :color="eventType.color">
                <v-icon color="white" :icon="eventType.icon"></v-icon>
              </v-avatar>
            </template>
            
            <v-list-item-title :class="{'text-grey': !eventType.enabled}">
              {{ eventType.name }}
              <v-chip
                v-if="!eventType.enabled"
                size="x-small"
                color="grey"
                class="ml-2"
              >
                Disabled
              </v-chip>
            </v-list-item-title>
            
            <template v-slot:append>
              <v-switch
                :model-value="eventType.enabled"
                color="primary"
                density="compact"
                hide-details
                @update:model-value="() => emit('toggleEventType', eventType.id)"
                class="mr-2"
              ></v-switch>
              
              <v-btn
                icon="mdi-pencil"
                variant="text"
                size="small"
                color="primary"
                @click="editEventType(eventType)"
                class="mr-1"
              ></v-btn>
              
              <v-btn
                icon="mdi-delete"
                variant="text"
                size="small"
                color="error"
                @click="handleRemove(eventType.id)"
              ></v-btn>
            </template>
          </v-list-item>
        </v-list>
        
        <v-alert
          v-else
          type="info"
          text="No event types defined. Add your first event type!"
          variant="tonal"
          class="mt-4"
        ></v-alert>
      </v-card-text>
    </v-card>
  </div>
</template>

<style scoped>
.v-list-item {
  padding: 12px;
  margin-bottom: 4px;
  border-radius: 8px;
}
.v-list-item:hover {
  background-color: rgba(0, 0, 0, 0.04);
}
</style>