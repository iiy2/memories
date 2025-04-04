import { 
  createUserWithEmailAndPassword, 
  signInWithEmailAndPassword, 
  signOut,
  sendPasswordResetEmail,
  updateProfile,
  onAuthStateChanged,
  type User,
} from 'firebase/auth'
import { auth } from './config'

// Register a new user
export const register = async (email: string, password: string, displayName: string) => {
  try {
    const userCredential = await createUserWithEmailAndPassword(auth, email, password)
    // Add the display name to the user
    if (auth.currentUser) {
      await updateProfile(auth.currentUser, {
        displayName
      })
    }
    return userCredential.user
  } catch (error) {
    throw error
  }
}

// Sign in an existing user
export const login = async (email: string, password: string) => {
  try {
    const userCredential = await signInWithEmailAndPassword(auth, email, password)
    return userCredential.user
  } catch (error) {
    throw error
  }
}

// Sign out the current user
export const logout = async () => {
  try {
    await signOut(auth)
    return true
  } catch (error) {
    throw error
  }
}

// Reset password
export const resetPassword = async (email: string) => {
  try {
    await sendPasswordResetEmail(auth, email)
    return true
  } catch (error) {
    throw error
  }
}

// Get the current user
export const getCurrentUser = (): User | null => {
  return auth.currentUser
}

// Subscribe to auth state changes
export const onAuthChange = (callback: (user: User | null) => void) => {
  return onAuthStateChanged(auth, callback)
}