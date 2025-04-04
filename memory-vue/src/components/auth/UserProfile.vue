<script setup lang="ts">
import { ref, computed } from 'vue'
import { getCurrentUser, logout } from '../../firebase/auth'

const emit = defineEmits<{
  (e: 'logout'): void
}>()

const user = ref(getCurrentUser())
const showMenu = ref(false)
const loading = ref(false)

const initials = computed(() => {
  if (!user.value?.displayName) return ''
  
  const nameParts = user.value.displayName.split(' ')
  if (nameParts.length === 1) {
    return nameParts[0].charAt(0).toUpperCase()
  } else {
    return (nameParts[0].charAt(0) + nameParts[nameParts.length - 1].charAt(0)).toUpperCase()
  }
})

const handleLogout = async () => {
  loading.value = true
  try {
    await logout()
    emit('logout')
  } catch (error) {
    console.error('Logout error:', error)
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div v-if="user">
    <v-menu
      v-model="showMenu"
      :close-on-content-click="false"
      location="bottom end"
    >
      <template v-slot:activator="{ props }">
        <v-btn
          v-bind="props"
          icon
          variant="text"
        >
          <v-avatar color="primary" size="36">
            <span class="text-white">{{ initials }}</span>
          </v-avatar>
        </v-btn>
      </template>
      
      <v-card min-width="200">
        <v-list>
          <v-list-item>
            <template v-slot:prepend>
              <v-avatar color="primary" size="36">
                <span class="text-white">{{ initials }}</span>
              </v-avatar>
            </template>
            <v-list-item-title>{{ user.displayName }}</v-list-item-title>
            <v-list-item-subtitle>{{ user.email }}</v-list-item-subtitle>
          </v-list-item>
        </v-list>
        
        <v-divider></v-divider>
        
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            variant="text"
            color="error"
            @click="handleLogout"
            :loading="loading"
          >
            <v-icon start>mdi-logout</v-icon>
            Logout
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-menu>
  </div>
</template>