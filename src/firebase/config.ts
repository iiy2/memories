import { initializeApp } from 'firebase/app'
import { getFirestore } from 'firebase/firestore'
import { getAuth } from 'firebase/auth'

// Firebase configuration
// NOTE: In a production app, these values should be stored in environment variables
// For this demo, we're placing them directly in the code
const firebaseConfig = {
  apiKey: "AIzaSyCAh1ikylWptE6qUPBcfiRPAue5TgRQ6C4",
  authDomain: "memories-419ca.firebaseapp.com",
  projectId: "memories-419ca",
  storageBucket: "memories-419ca.firebasestorage.app",
  messagingSenderId: "1092339841271",
  appId: "1:1092339841271:web:28d126d763e8f9dc537bf2",
  measurementId: "G-80VYXXMK1P"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig)

// Initialize Firestore
const db = getFirestore(app)

// Initialize Firebase Authentication
const auth = getAuth(app)

export { db, auth }