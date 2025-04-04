import { 
  collection,
  doc,
  addDoc,
  getDoc,
  getDocs,
  updateDoc,
  deleteDoc,
  query,
  where,
  orderBy,
  Timestamp,
  setDoc,
  onSnapshot,
  QuerySnapshot,
  type DocumentData,
} from 'firebase/firestore'
import { db } from './config'

// Event Type interface for Firestore
export interface FirestoreEventType {
  id: string;
  name: string;
  color: string;
  icon: string;
  enabled: boolean;
  userId: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

// Event interface for Firestore
export interface FirestoreEvent {
  id: string;
  title: string;
  date: Timestamp;
  description: string;
  category: string;
  userId: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

// Convert local Date to Firestore Timestamp
export const dateToTimestamp = (date: Date): Timestamp => {
  return Timestamp.fromDate(date)
}

// Convert Firestore Timestamp to local Date
export const timestampToDate = (timestamp: Timestamp): Date => {
  return timestamp.toDate()
}

// Events Collection

// Get all events for a user
export const getUserEvents = async (userId: string) => {
  try {
    const eventsRef = collection(db, 'events')
    const q = query(
      eventsRef,
      where('userId', '==', userId),
      orderBy('date', 'desc')
    )
    const querySnapshot = await getDocs(q)
    
    return querySnapshot.docs.map(doc => {
      const data = doc.data() as FirestoreEvent
      return {
        ...data,
        id: doc.id
      }
    })
  } catch (error) {
    throw error
  }
}

// Subscribe to user events (real-time updates)
export const subscribeToUserEvents = (
  userId: string,
  callback: (events: FirestoreEvent[]) => void
) => {
  const eventsRef = collection(db, 'events')
  const q = query(
    eventsRef,
    where('userId', '==', userId),
    orderBy('date', 'desc')
  )
  
  return onSnapshot(q, (querySnapshot: QuerySnapshot<DocumentData>) => {
    const events = querySnapshot.docs.map(doc => {
      const data = doc.data() as FirestoreEvent
      return {
        ...data,
        id: doc.id
      }
    })
    callback(events)
  })
}

// Add a new event
export const addEvent = async (event: Omit<FirestoreEvent, 'id' | 'createdAt' | 'updatedAt'>) => {
  try {
    const now = Timestamp.now()
    const eventWithTimestamps = {
      ...event,
      createdAt: now,
      updatedAt: now
    }
    
    const docRef = await addDoc(collection(db, 'events'), eventWithTimestamps)
    return {
      ...eventWithTimestamps,
      id: docRef.id
    }
  } catch (error) {
    throw error
  }
}

// Update an event
export const updateEvent = async (id: string, event: Partial<Omit<FirestoreEvent, 'id' | 'createdAt' | 'updatedAt' | 'userId'>>) => {
  try {
    const eventRef = doc(db, 'events', id)
    const updatedEvent = {
      ...event,
      updatedAt: Timestamp.now()
    }
    
    await updateDoc(eventRef, updatedEvent)
    return id
  } catch (error) {
    throw error
  }
}

// Delete an event
export const deleteEvent = async (id: string) => {
  try {
    const eventRef = doc(db, 'events', id)
    await deleteDoc(eventRef)
    return id
  } catch (error) {
    throw error
  }
}

// Event Types Collection

// Get all event types for a user
export const getUserEventTypes = async (userId: string) => {
  try {
    const eventTypesRef = collection(db, 'eventTypes')
    const q = query(
      eventTypesRef,
      where('userId', '==', userId),
      orderBy('createdAt', 'asc')
    )
    const querySnapshot = await getDocs(q)
    
    return querySnapshot.docs.map(doc => {
      const data = doc.data() as FirestoreEventType
      return {
        ...data,
        id: doc.id
      }
    })
  } catch (error) {
    throw error
  }
}

// Subscribe to user event types (real-time updates)
export const subscribeToUserEventTypes = (
  userId: string,
  callback: (eventTypes: FirestoreEventType[]) => void
) => {
  const eventTypesRef = collection(db, 'eventTypes')
  const q = query(
    eventTypesRef,
    where('userId', '==', userId),
    orderBy('createdAt', 'asc')
  )
  
  return onSnapshot(q, (querySnapshot: QuerySnapshot<DocumentData>) => {
    const eventTypes = querySnapshot.docs.map(doc => {
      const data = doc.data() as FirestoreEventType
      return {
        ...data,
        id: doc.id
      }
    })
    callback(eventTypes)
  })
}

// Add a new event type
export const addEventType = async (
  eventType: Omit<FirestoreEventType, 'id' | 'createdAt' | 'updatedAt'>
) => {
  try {
    const now = Timestamp.now()
    const eventTypeWithTimestamps = {
      ...eventType,
      createdAt: now,
      updatedAt: now
    }
    
    const docRef = await addDoc(collection(db, 'eventTypes'), eventTypeWithTimestamps)
    return {
      ...eventTypeWithTimestamps,
      id: docRef.id
    }
  } catch (error) {
    throw error
  }
}

// Update an event type
export const updateEventType = async (
  id: string,
  eventType: Partial<Omit<FirestoreEventType, 'id' | 'createdAt' | 'updatedAt' | 'userId'>>
) => {
  try {
    const eventTypeRef = doc(db, 'eventTypes', id)
    const updatedEventType = {
      ...eventType,
      updatedAt: Timestamp.now()
    }
    
    await updateDoc(eventTypeRef, updatedEventType)
    return id
  } catch (error) {
    throw error
  }
}

// Delete an event type
export const deleteEventType = async (id: string) => {
  try {
    const eventTypeRef = doc(db, 'eventTypes', id)
    await deleteDoc(eventTypeRef)
    return id
  } catch (error) {
    throw error
  }
}

// Initialize default event types for a new user
export const initializeDefaultEventTypes = async (userId: string) => {
  try {
    const defaultEventTypes = [
      { id: 'personal', name: 'Personal', color: 'blue', icon: 'mdi-account', enabled: true },
      { id: 'work', name: 'Work', color: 'amber', icon: 'mdi-briefcase', enabled: true },
      { id: 'family', name: 'Family', color: 'pink', icon: 'mdi-home-heart', enabled: true },
      { id: 'health', name: 'Health', color: 'green', icon: 'mdi-heart-pulse', enabled: true },
      { id: 'travel', name: 'Travel', color: 'purple', icon: 'mdi-airplane', enabled: true },
      { id: 'other', name: 'Other', color: 'grey', icon: 'mdi-star', enabled: true }
    ]
    
    const now = Timestamp.now()
    const batch = []
    
    for (const eventType of defaultEventTypes) {
      const eventTypeWithMeta = {
        ...eventType,
        userId,
        createdAt: now,
        updatedAt: now
      }
      
      batch.push(
        setDoc(
          doc(db, 'eventTypes', eventType.id), 
          eventTypeWithMeta
        )
      )
    }
    
    await Promise.all(batch)
    return true
  } catch (error) {
    throw error
  }
}

// User Settings Collection

// Get user settings
export const getUserSettings = async (userId: string) => {
  try {
    const settingsRef = doc(db, 'userSettings', userId)
    const docSnap = await getDoc(settingsRef)
    
    if (docSnap.exists()) {
      return docSnap.data()
    } else {
      return null
    }
  } catch (error) {
    throw error
  }
}

// Update user settings
export const updateUserSettings = async (userId: string, settings: any) => {
  try {
    const settingsRef = doc(db, 'userSettings', userId)
    const updatedSettings = {
      ...settings,
      updatedAt: Timestamp.now()
    }
    
    await setDoc(settingsRef, updatedSettings, { merge: true })
    return userId
  } catch (error) {
    throw error
  }
}