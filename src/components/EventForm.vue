<script setup lang="ts">
import { ref } from 'vue'

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
const categories = ['Personal', 'Work', 'Family', 'Health', 'Travel', 'Other']

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
  <v-card class="mb-4">
    <v-card-title class="text-h5">
      <v-icon start icon="mdi-calendar-plus"></v-icon>
      Add New Event
    </v-card-title>
    
    <v-card-text>
      <v-form v-model="formValid" @submit.prevent="submitForm">
        <v-text-field
          v-model="title"
          label="Event Title"
          :rules="titleRules"
          required
          variant="outlined"
          density="comfortable"
        ></v-text-field>
        
        <v-text-field
          v-model="date"
          label="Date"
          type="date"
          :rules="dateRules"
          required
          variant="outlined"
          density="comfortable"
        ></v-text-field>
        
        <v-select
          v-model="category"
          label="Category"
          :items="categories"
          :rules="categoryRules"
          required
          variant="outlined"
          density="comfortable"
        ></v-select>
        
        <v-textarea
          v-model="description"
          label="Description"
          variant="outlined"
          density="comfortable"
          rows="3"
        ></v-textarea>
        
        <v-btn 
          type="submit" 
          color="primary" 
          block 
          :disabled="!formValid"
          class="mt-4"
        >
          Save Event
        </v-btn>
      </v-form>
    </v-card-text>
  </v-card>
</template>