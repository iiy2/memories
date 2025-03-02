import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { User } from 'firebase/auth'
import { 
  login as firebaseLogin, 
  register as firebaseRegister, 
  logout as firebaseLogout,
  onAuthChange,
  getCurrentUser
} from '../firebase/auth'
import { initializeDefaultEventTypes } from '../firebase/firestore'

export const useAuthStore = defineStore('auth', () => {
  // State
  const user = ref<User | null>(getCurrentUser())
  const loading = ref(false)
  const error = ref<string | null>(null)
  
  // Getters
  const isAuthenticated = computed(() => !!user.value)
  const userName = computed(() => user.value?.displayName || '')
  const userEmail = computed(() => user.value?.email || '')
  const userId = computed(() => user.value?.uid || '')
  
  // Actions
  const login = async (email: string, password: string) => {
    loading.value = true
    error.value = null
    
    try {
      const loggedInUser = await firebaseLogin(email, password)
      user.value = loggedInUser
      return loggedInUser
    } catch (err: any) {
      console.error('Login error:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const register = async (email: string, password: string, name: string) => {
    loading.value = true
    error.value = null
    
    try {
      const newUser = await firebaseRegister(email, password, name)
      user.value = newUser
      
      // Initialize default event types for the new user
      await initializeDefaultEventTypes(newUser.uid)
      
      return newUser
    } catch (err: any) {
      console.error('Registration error:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const logout = async () => {
    loading.value = true
    error.value = null
    
    try {
      await firebaseLogout()
      user.value = null
    } catch (err: any) {
      console.error('Logout error:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }
  
  // Listen to auth state changes
  onAuthChange((authUser) => {
    user.value = authUser
  })
  
  return {
    user,
    loading,
    error,
    isAuthenticated,
    userName,
    userEmail,
    userId,
    login,
    register,
    logout
  }
})