import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { 
  FirestoreEventType, 
  addEventType as firestoreAddEventType,
  updateEventType as firestoreUpdateEventType,
  deleteEventType as firestoreDeleteEventType,
  getUserEventTypes,
  subscribeToUserEventTypes
} from '../firebase/firestore'
import { useAuthStore } from './auth'

export interface EventType {
  id: string;
  name: string;
  color: string;
  icon: string;
  enabled: boolean;
}

export const useEventTypeStore = defineStore('eventTypes', () => {
  // State
  const eventTypes = ref<EventType[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)
  const unsubscribe = ref<(() => void) | null>(null)
  
  // Getters
  const enabledEventTypes = computed(() => {
    return eventTypes.value.filter(et => et.enabled)
  })
  
  const sortedEventTypes = computed(() => {
    return [...eventTypes.value].sort((a, b) => {
      // Enabled types first, then alphabetical
      if (a.enabled && !b.enabled) return -1
      if (!a.enabled && b.enabled) return 1
      return a.name.localeCompare(b.name)
    })
  })
  
  // Convert Firestore event type to local event type
  const firestoreToLocalEventType = (firestoreEventType: FirestoreEventType): EventType => {
    return {
      id: firestoreEventType.id,
      name: firestoreEventType.name,
      color: firestoreEventType.color,
      icon: firestoreEventType.icon,
      enabled: firestoreEventType.enabled
    }
  }
  
  // Actions
  const fetchEventTypes = async () => {
    const authStore = useAuthStore()
    if (!authStore.isAuthenticated) return
    
    loading.value = true
    error.value = null
    
    try {
      const firestoreEventTypes = await getUserEventTypes(authStore.userId)
      eventTypes.value = firestoreEventTypes.map(firestoreToLocalEventType)
    } catch (err: any) {
      console.error('Error fetching event types:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const subscribeToEventTypes = () => {
    const authStore = useAuthStore()
    if (!authStore.isAuthenticated) return
    
    // Unsubscribe from any previous subscription
    if (unsubscribe.value) {
      unsubscribe.value()
    }
    
    // Subscribe to event types updates
    unsubscribe.value = subscribeToUserEventTypes(
      authStore.userId,
      (firestoreEventTypes) => {
        eventTypes.value = firestoreEventTypes.map(firestoreToLocalEventType)
      }
    )
  }
  
  const unsubscribeFromEventTypes = () => {
    if (unsubscribe.value) {
      unsubscribe.value()
      unsubscribe.value = null
    }
  }
  
  const addEventType = async (eventType: Omit<EventType, 'id'>) => {
    const authStore = useAuthStore()
    if (!authStore.isAuthenticated) return
    
    loading.value = true
    error.value = null
    
    try {
      const firestoreEventType = await firestoreAddEventType({
        name: eventType.name,
        color: eventType.color,
        icon: eventType.icon,
        enabled: eventType.enabled,
        userId: authStore.userId
      })
      
      return firestoreEventType.id
    } catch (err: any) {
      console.error('Error adding event type:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const updateEventType = async (id: string, eventTypeData: Partial<Omit<EventType, 'id'>>) => {
    loading.value = true
    error.value = null
    
    try {
      await firestoreUpdateEventType(id, eventTypeData)
      return id
    } catch (err: any) {
      console.error('Error updating event type:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const deleteEventType = async (id: string) => {
    loading.value = true
    error.value = null
    
    try {
      await firestoreDeleteEventType(id)
      return id
    } catch (err: any) {
      console.error('Error deleting event type:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const toggleEventType = async (id: string) => {
    const eventType = eventTypes.value.find(et => et.id === id)
    if (!eventType) return
    
    return updateEventType(id, { enabled: !eventType.enabled })
  }
  
  return {
    eventTypes,
    loading,
    error,
    enabledEventTypes,
    sortedEventTypes,
    fetchEventTypes,
    subscribeToEventTypes,
    unsubscribeFromEventTypes,
    addEventType,
    updateEventType,
    deleteEventType,
    toggleEventType
  }
})