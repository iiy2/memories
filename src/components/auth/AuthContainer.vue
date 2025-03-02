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
    <v-container>
      <v-row justify="center" align="center" style="min-height: 100vh;">
        <v-col cols="12" sm="10" md="8" lg="6">
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
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>

<style scoped>
.auth-container {
  background-color: #f5f5f5;
  min-height: 100vh;
}
</style>