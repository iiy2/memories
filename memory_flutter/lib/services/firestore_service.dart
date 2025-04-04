import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memory_flutter/models/event.dart';
import 'package:memory_flutter/models/event_type.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  CollectionReference get _eventsCollection => _firestore.collection('events');
  CollectionReference get _eventTypesCollection => _firestore.collection('eventTypes');
  
  // EVENTS CRUD OPERATIONS
  
  // Stream of events for a user
  Stream<List<Event>> eventsStream(String userId) {
    return _eventsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    });
  }
  
  // Add event
  Future<String> addEvent(Event event) async {
    final docRef = await _eventsCollection.add(event.toFirestore());
    return docRef.id;
  }
  
  // Update event
  Future<void> updateEvent(String id, Map<String, dynamic> data) async {
    final now = DateTime.now();
    await _eventsCollection.doc(id).update({
      ...data,
      'updatedAt': Timestamp.fromDate(now),
    });
  }
  
  // Delete event
  Future<void> deleteEvent(String id) async {
    await _eventsCollection.doc(id).delete();
  }
  
  // Get a single event
  Future<Event?> getEvent(String id) async {
    final doc = await _eventsCollection.doc(id).get();
    if (doc.exists) {
      return Event.fromFirestore(doc);
    }
    return null;
  }
  
  // EVENT TYPES CRUD OPERATIONS
  
  // Stream of event types for a user
  Stream<List<EventType>> eventTypesStream(String userId) {
    return _eventTypesCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => EventType.fromFirestore(doc)).toList();
    });
  }
  
  // Add event type
  Future<String> addEventType(EventType eventType) async {
    final docRef = await _eventTypesCollection.add(eventType.toFirestore());
    return docRef.id;
  }
  
  // Update event type
  Future<void> updateEventType(String id, Map<String, dynamic> data) async {
    final now = DateTime.now();
    await _eventTypesCollection.doc(id).update({
      ...data,
      'updatedAt': Timestamp.fromDate(now),
    });
  }
  
  // Delete event type
  Future<void> deleteEventType(String id) async {
    await _eventTypesCollection.doc(id).delete();
  }
  
  // Get a single event type
  Future<EventType?> getEventType(String id) async {
    final doc = await _eventTypesCollection.doc(id).get();
    if (doc.exists) {
      return EventType.fromFirestore(doc);
    }
    return null;
  }
  
  // Toggle event type enabled status
  Future<void> toggleEventType(String id) async {
    try {
      final doc = await _eventTypesCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final now = DateTime.now();
        final currentEnabled = data['enabled'];
        
        // Make sure we have a boolean value (defaulting to true if not set)
        final isEnabled = currentEnabled is bool ? currentEnabled : true;
        
        // Toggle to the opposite value
        await _eventTypesCollection.doc(id).update({
          'enabled': !isEnabled,
          'updatedAt': Timestamp.fromDate(now),
        });
        
        print('Toggled event type $id from $isEnabled to ${!isEnabled}');
      }
    } catch (e) {
      print('Error toggling event type: $e');
      throw e;
    }
  }
  
  // Initialize default event types for a new user
  Future<void> initializeDefaultEventTypes(String userId) async {
    // Check if user already has event types
    final snapshot = await _eventTypesCollection
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    
    // If user has no event types, add defaults
    if (snapshot.docs.isEmpty) {
      final defaultTypes = EventType.getDefaultEventTypes(userId);
      
      // Add each default type
      for (final typeData in defaultTypes) {
        await _eventTypesCollection.add(typeData);
      }
    }
  }
}