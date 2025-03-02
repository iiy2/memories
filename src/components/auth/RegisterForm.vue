<script setup lang="ts">
import { ref } from 'vue'
import { register } from '../../firebase/auth'
import { initializeDefaultEventTypes } from '../../firebase/firestore'

const emit = defineEmits<{
  (e: 'register-success'): void
  (e: 'show-login'): void
}>()

const name = ref('')
const email = ref('')
const password = ref('')
const confirmPassword = ref('')
const showPassword = ref(false)
const showConfirmPassword = ref(false)
const formValid = ref(false)
const loading = ref(false)
const error = ref('')

const nameRules = [
  (v: string) => !!v || 'Name is required',
  (v: string) => v.length <= 50 || 'Name must be less than 50 characters'
]

const emailRules = [
  (v: string) => !!v || 'Email is required',
  (v: string) => /.+@.+\..+/.test(v) || 'Email must be valid'
]

const passwordRules = [
  (v: string) => !!v || 'Password is required',
  (v: string) => v.length >= 6 || 'Password must be at least 6 characters'
]

const confirmPasswordRules = [
  (v: string) => !!v || 'Confirm password is required',
  (v: string) => v === password.value || 'Passwords must match'
]

const handleRegister = async () => {
  if (!formValid.value) return
  
  loading.value = true
  error.value = ''
  
  try {
    const user = await register(email.value, password.value, name.value)
    
    // Initialize default event types for the new user
    await initializeDefaultEventTypes(user.uid)
    
    emit('register-success')
  } catch (err: any) {
    switch (err.code) {
      case 'auth/email-already-in-use':
        error.value = 'Email is already in use. Please use a different email or login.'
        break
      case 'auth/invalid-email':
        error.value = 'Invalid email address.'
        break
      case 'auth/weak-password':
        error.value = 'Password is too weak. Please use a stronger password.'
        break
      default:
        error.value = `Error: ${err.message}`
    }
  } finally {
    loading.value = false
  }
}

const goToLogin = () => {
  emit('show-login')
}
</script>

<template>
  <v-card class="mx-auto" :elevation="$vuetify && $vuetify.display.smAndDown ? 0 : 2">
    <v-card-title class="text-h5 text-center py-4">
      <v-icon icon="mdi-account-plus" class="mr-2" :size="$vuetify && $vuetify.display.smAndDown ? 'default' : 'large'"></v-icon>
      Create Account
    </v-card-title>
    
    <v-divider></v-divider>
    
    <v-card-text class="pt-4">
      <v-form v-model="formValid" @submit.prevent="handleRegister">
        <v-text-field
          v-model="name"
          label="Full Name"
          :rules="nameRules"
          required
          variant="outlined"
          prepend-inner-icon="mdi-account"
        ></v-text-field>
        
        <v-text-field
          v-model="email"
          label="Email"
          type="email"
          :rules="emailRules"
          required
          variant="outlined"
          prepend-inner-icon="mdi-email"
        ></v-text-field>
        
        <v-text-field
          v-model="password"
          label="Password"
          :type="showPassword ? 'text' : 'password'"
          :rules="passwordRules"
          required
          variant="outlined"
          prepend-inner-icon="mdi-lock"
          :append-inner-icon="showPassword ? 'mdi-eye-off' : 'mdi-eye'"
          @click:append-inner="showPassword = !showPassword"
        ></v-text-field>
        
        <v-text-field
          v-model="confirmPassword"
          label="Confirm Password"
          :type="showConfirmPassword ? 'text' : 'password'"
          :rules="confirmPasswordRules"
          required
          variant="outlined"
          prepend-inner-icon="mdi-lock-check"
          :append-inner-icon="showConfirmPassword ? 'mdi-eye-off' : 'mdi-eye'"
          @click:append-inner="showConfirmPassword = !showConfirmPassword"
        ></v-text-field>
        
        <v-alert
          v-if="error"
          type="error"
          variant="tonal"
          closable
          class="mb-4"
        >
          {{ error }}
        </v-alert>
        
        <v-btn
          type="submit"
          color="primary"
          block
          :loading="loading"
          :disabled="!formValid"
          class="mt-4"
        >
          Register
        </v-btn>
      </v-form>
      
      <v-divider class="my-4"></v-divider>
      
      <div class="text-center">
        <p class="text-body-2 mb-2">Already have an account?</p>
        <v-btn
          color="secondary"
          variant="outlined"
          @click="goToLogin"
          block
        >
          Log In
        </v-btn>
      </div>
    </v-card-text>
  </v-card>
</template>