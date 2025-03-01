<script setup lang="ts">
import { ref, onMounted } from 'vue'

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
  (e: 'addEvent', event: {
    title: string;
    date: string;
    description: string;
    category: string;
  }): void
}>()

const title = ref('')
const date = ref('')
const description = ref('')
const category = ref('')
const formValid = ref(false)

// Set default date to today
onMounted(() => {
  const today = new Date()
  const year = today.getFullYear()
  const month = String(today.getMonth() + 1).padStart(2, '0')
  const day = String(today.getDate()).padStart(2, '0')
  date.value = `${year}-${month}-${day}`
  
  // Set default category to first available
  if (props.eventTypes.length > 0) {
    category.value = props.eventTypes[0].name
  }
})

const titleRules = [
  (v: string) => !!v || 'Title is required',
  (v: string) => v.length <= 100 || 'Title must be less than 100 characters'
]

const dateRules = [
  (v: string) => !!v || 'Date is required'
]

const categoryRules = [
  (v: string) => !!v || 'Category is required'
]

// Get event type by name
function getEventType(name: string): EventType | undefined {
  return props.eventTypes.find(et => et.name === name)
}

function submitForm() {
  if (!formValid.value) return
  
  emit('addEvent', {
    title: title.value,
    date: date.value,
    description: description.value,
    category: category.value
  })
  
  // Reset form
  title.value = ''
  date.value = ''
  description.value = ''
  category.value = ''
}
</script>

<template>
  <v-form v-model="formValid" @submit.prevent="submitForm">
    <v-text-field
      v-model="title"
      label="Event Title"
      :rules="titleRules"
      required
      variant="outlined"
      density="comfortable"
      autofocus
    ></v-text-field>
    
    <v-row>
      <v-col cols="12" sm="6">
        <v-text-field
          v-model="date"
          label="Date"
          type="date"
          :rules="dateRules"
          required
          variant="outlined"
          density="comfortable"
        ></v-text-field>
      </v-col>
      
      <v-col cols="12" sm="6">
        <v-select
          v-model="category"
          label="Category"
          :items="props.eventTypes.map(et => et.name)"
          :rules="categoryRules"
          required
          variant="outlined"
          density="comfortable"
          :disabled="props.eventTypes.length === 0"
          :hint="props.eventTypes.length === 0 ? 'Add event types in Settings' : ''"
          persistent-hint
        >
          <template v-slot:selection="{ item }">
            <template v-if="getEventType(item.raw)">
              <v-icon :icon="getEventType(item.raw)?.icon" class="mr-2" :color="getEventType(item.raw)?.color"></v-icon>
              {{ item.raw }}
            </template>
          </template>
          <template v-slot:item="{ item, props }">
            <v-list-item v-bind="props">
              <template v-slot:prepend>
                <v-icon 
                  v-if="getEventType(item.raw)"
                  :icon="getEventType(item.raw)?.icon" 
                  :color="getEventType(item.raw)?.color"
                ></v-icon>
              </template>
              <v-list-item-title>{{ item.raw }}</v-list-item-title>
            </v-list-item>
          </template>
        </v-select>
      </v-col>
    </v-row>
    
    <v-textarea
      v-model="description"
      label="Description"
      variant="outlined"
      density="comfortable"
      rows="4"
      placeholder="Write details about this event..."
      hint="Include any details you want to remember about this event"
      persistent-hint
    ></v-textarea>
    
    <div class="d-flex justify-end mt-4">
      <v-btn 
        type="submit" 
        color="primary" 
        :disabled="!formValid"
        size="large"
      >
        <v-icon start>mdi-content-save</v-icon>
        Save Event
      </v-btn>
    </div>
  </v-form>
</template>