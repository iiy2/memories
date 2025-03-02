<script setup lang="ts">
import { ref } from 'vue'
import { login, resetPassword } from '../../firebase/auth'

const emit = defineEmits<{
  (e: 'login-success'): void
  (e: 'show-register'): void
}>()

const email = ref('')
const password = ref('')
const showPassword = ref(false)
const formValid = ref(false)
const loading = ref(false)
const error = ref('')
const showForgotPassword = ref(false)
const resetEmail = ref('')
const resetSuccess = ref(false)
const resetError = ref('')

const emailRules = [
  (v: string) => !!v || 'Email is required',
  (v: string) => /.+@.+\..+/.test(v) || 'Email must be valid'
]

const passwordRules = [
  (v: string) => !!v || 'Password is required',
  (v: string) => v.length >= 6 || 'Password must be at least 6 characters'
]

const handleLogin = async () => {
  if (!formValid.value) return
  
  loading.value = true
  error.value = ''
  
  try {
    await login(email.value, password.value)
    emit('login-success')
  } catch (err: any) {
    switch (err.code) {
      case 'auth/user-not-found':
        error.value = 'User not found. Please check your email or register.'
        break
      case 'auth/wrong-password':
        error.value = 'Incorrect password. Please try again.'
        break
      case 'auth/too-many-requests':
        error.value = 'Too many failed attempts. Please try again later.'
        break
      case 'auth/invalid-credential':
        error.value = 'Invalid credentials. Please check your email and password.'
        break
      default:
        error.value = `Error: ${err.message}`
    }
  } finally {
    loading.value = false
  }
}

const handleResetPassword = async () => {
  if (!resetEmail.value) {
    resetError.value = 'Please enter your email address'
    return
  }
  
  loading.value = true
  resetError.value = ''
  resetSuccess.value = false
  
  try {
    await resetPassword(resetEmail.value)
    resetSuccess.value = true
  } catch (err: any) {
    if (err.code === 'auth/user-not-found') {
      resetError.value = 'No account found with this email address'
    } else {
      resetError.value = `Error: ${err.message}`
    }
  } finally {
    loading.value = false
  }
}

const goToRegister = () => {
  emit('show-register')
}
</script>

<template>
  <v-card class="mx-auto" max-width="500">
    <v-card-title class="text-h5 text-center py-4">
      <v-icon icon="mdi-account" class="mr-2" size="large"></v-icon>
      Login to Memory AI
    </v-card-title>
    
    <v-divider></v-divider>
    
    <v-card-text class="pt-4">
      <div v-if="!showForgotPassword">
        <v-form v-model="formValid" @submit.prevent="handleLogin">
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
          
          <v-alert
            v-if="error"
            type="error"
            variant="tonal"
            closable
            class="mb-4"
          >
            {{ error }}
          </v-alert>
          
          <div class="d-flex justify-space-between align-center mb-4">
            <v-btn
              variant="text"
              color="primary"
              @click="showForgotPassword = true"
              size="small"
            >
              Forgot Password?
            </v-btn>
            
            <v-btn
              type="submit"
              color="primary"
              :loading="loading"
              :disabled="!formValid"
            >
              Login
            </v-btn>
          </div>
        </v-form>
        
        <v-divider class="my-4"></v-divider>
        
        <div class="text-center">
          <p class="text-body-2 mb-2">Don't have an account?</p>
          <v-btn
            color="secondary"
            variant="outlined"
            @click="goToRegister"
            block
          >
            Register Now
          </v-btn>
        </div>
      </div>
      
      <!-- Forgot Password Form -->
      <div v-else>
        <h3 class="text-h6 mb-4">Reset Password</h3>
        
        <p class="text-body-2 mb-4">
          Enter your email address and we'll send you a link to reset your password.
        </p>
        
        <v-form @submit.prevent="handleResetPassword">
          <v-text-field
            v-model="resetEmail"
            label="Email"
            type="email"
            required
            variant="outlined"
            prepend-inner-icon="mdi-email"
          ></v-text-field>
          
          <v-alert
            v-if="resetError"
            type="error"
            variant="tonal"
            closable
            class="mb-4"
          >
            {{ resetError }}
          </v-alert>
          
          <v-alert
            v-if="resetSuccess"
            type="success"
            variant="tonal"
            closable
            class="mb-4"
          >
            Password reset email sent! Check your inbox.
          </v-alert>
          
          <div class="d-flex justify-space-between align-center">
            <v-btn
              variant="text"
              @click="showForgotPassword = false"
            >
              Back to Login
            </v-btn>
            
            <v-btn
              type="submit"
              color="primary"
              :loading="loading"
            >
              Send Reset Link
            </v-btn>
          </div>
        </v-form>
      </div>
    </v-card-text>
  </v-card>
</template>