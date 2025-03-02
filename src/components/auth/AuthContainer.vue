<script setup lang="ts">
import { ref } from 'vue'
import LoginForm from './LoginForm.vue'
import RegisterForm from './RegisterForm.vue'

const emit = defineEmits<{
  (e: 'auth-success'): void
}>()

const showRegister = ref(false)

const handleLoginSuccess = () => {
  emit('auth-success')
}

const handleRegisterSuccess = () => {
  emit('auth-success')
}

const toggleForm = () => {
  showRegister.value = !showRegister.value
}
</script>

<template>
  <div class="auth-container">
    <v-container class="fill-height">
      <v-row justify="center" align="center">
        <v-col cols="12" sm="10" md="8" lg="6" xl="5">
          <!-- App logo/branding -->
          <div class="text-center mb-6 d-none d-sm-block">
            <v-avatar color="primary" size="80" class="mb-3">
              <v-icon size="40" color="white">mdi-calendar-text</v-icon>
            </v-avatar>
            <h1 class="text-h4 font-weight-bold primary--text">Memory AI</h1>
            <p class="text-subtitle-1 text-medium-emphasis">Your Life Events Tracker</p>
          </div>
          
          <!-- Mobile branding -->
          <div class="text-center mb-4 d-sm-none">
            <v-avatar color="primary" size="50" class="mb-2">
              <v-icon size="28" color="white">mdi-calendar-text</v-icon>
            </v-avatar>
            <h1 class="text-h5 font-weight-bold primary--text">Memory AI</h1>
          </div>
          
          <v-slide-y-transition>
            <LoginForm
              v-if="!showRegister"
              @login-success="handleLoginSuccess"
              @show-register="toggleForm"
            />
            <RegisterForm
              v-else
              @register-success="handleRegisterSuccess"
              @show-login="toggleForm"
            />
          </v-slide-y-transition>
          
          <!-- Footer -->
          <div class="text-center mt-6 text-caption text-medium-emphasis">
            <p>&copy; {{ new Date().getFullYear() }} Memory AI - Your secure and private life events tracker.</p>
            <p class="mt-1">All data is stored securely and is accessible only to you.</p>
          </div>
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>

<style scoped>
.auth-container {
  background-color: #f5f5f5;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

@media (max-width: 600px) {
  .auth-container {
    background-color: white;
  }
}
</style>