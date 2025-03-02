import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { 
  FirestoreEvent, 
  addEvent as firestoreAddEvent,
  updateEvent as firestoreUpdateEvent,
  deleteEvent as firestoreDeleteEvent,
  getUserEvents,
  subscribeToUserEvents,
  dateToTimestamp,
  timestampToDate
} from '../firebase/firestore'
import { useAuthStore } from './auth'
import { Timestamp } from 'firebase/firestore'

// Interface for local events (with Date objects instead of Timestamps)
export interface Event {
  id: string;
  title: string;
  date: Date;
  description: string;
  category: string;
}

export const useEventStore = defineStore('events', () => {
  // State
  const events = ref<Event[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)
  const unsubscribe = ref<(() => void) | null>(null)
  
  // Getters
  const sortedEvents = computed(() => {
    return [...events.value].sort((a, b) => b.date.getTime() - a.date.getTime())
  })
  
  const eventsByCategory = computed(() => {
    const result: Record<string, Event[]> = {}
    
    for (const event of events.value) {
      if (!result[event.category]) {
        result[event.category] = []
      }
      result[event.category].push(event)
    }
    
    // Sort events in each category by date
    for (const category in result) {
      result[category].sort((a, b) => b.date.getTime() - a.date.getTime())
    }
    
    return result
  })
  
  // Convert Firestore event to local event (Timestamp to Date)
  const firestoreToLocalEvent = (firestoreEvent: FirestoreEvent): Event => {
    return {
      id: firestoreEvent.id,
      title: firestoreEvent.title,
      date: timestampToDate(firestoreEvent.date),
      description: firestoreEvent.description,
      category: firestoreEvent.category
    }
  }
  
  // Actions
  const fetchEvents = async () => {
    const authStore = useAuthStore()
    if (!authStore.isAuthenticated) return
    
    loading.value = true
    error.value = null
    
    try {
      const firestoreEvents = await getUserEvents(authStore.userId)
      events.value = firestoreEvents.map(firestoreToLocalEvent)
    } catch (err: any) {
      console.error('Error fetching events:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const subscribeToEvents = () => {
    const authStore = useAuthStore()
    if (!authStore.isAuthenticated) return
    
    // Unsubscribe from any previous subscription
    if (unsubscribe.value) {
      unsubscribe.value()
    }
    
    // Subscribe to events updates
    unsubscribe.value = subscribeToUserEvents(
      authStore.userId,
      (firestoreEvents) => {
        events.value = firestoreEvents.map(firestoreToLocalEvent)
      }
    )
  }
  
  const unsubscribeFromEvents = () => {
    if (unsubscribe.value) {
      unsubscribe.value()
      unsubscribe.value = null
    }
  }
  
  const addEvent = async (event: Omit<Event, 'id'>) => {
    const authStore = useAuthStore()
    if (!authStore.isAuthenticated) return
    
    loading.value = true
    error.value = null
    
    try {
      const firestoreEvent = await firestoreAddEvent({
        title: event.title,
        date: dateToTimestamp(event.date),
        description: event.description,
        category: event.category,
        userId: authStore.userId
      })
      
      return firestoreEvent.id
    } catch (err: any) {
      console.error('Error adding event:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const updateEvent = async (id: string, eventData: Partial<Omit<Event, 'id'>>) => {
    loading.value = true
    error.value = null
    
    try {
      // Convert date to Timestamp if present
      const firestoreEventData: any = { ...eventData }
      if (eventData.date) {
        firestoreEventData.date = dateToTimestamp(eventData.date)
      }
      
      await firestoreUpdateEvent(id, firestoreEventData)
      return id
    } catch (err: any) {
      console.error('Error updating event:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const deleteEvent = async (id: string) => {
    loading.value = true
    error.value = null
    
    try {
      await firestoreDeleteEvent(id)
      return id
    } catch (err: any) {
      console.error('Error deleting event:', err)
      error.value = err.message
      throw err
    } finally {
      loading.value = false
    }
  }
  
  return {
    events,
    loading,
    error,
    sortedEvents,
    eventsByCategory,
    fetchEvents,
    subscribeToEvents,
    unsubscribeFromEvents,
    addEvent,
    updateEvent,
    deleteEvent
  }
})