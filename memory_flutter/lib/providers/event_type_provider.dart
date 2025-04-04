import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memory_flutter/models/event_type.dart';
import 'package:memory_flutter/services/firestore_service.dart';

class EventTypeProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<EventType> _eventTypes = [];
  bool _loading = false;
  String? _error;
  StreamSubscription<List<EventType>>? _eventTypesSubscription;
  
  // Getters
  List<EventType> get eventTypes => _eventTypes;
  bool get isLoading => _loading;
  String? get error => _error;
  
  // Get only enabled event types
  List<EventType> get enabledEventTypes {
    return _eventTypes.where((type) => type.enabled).toList();
  }
  
  // Get sorted event types (enabled first, then alphabetically)
  List<EventType> get sortedEventTypes {
    final sortedList = List<EventType>.from(_eventTypes);
    sortedList.sort((a, b) {
      if (a.enabled && !b.enabled) return -1;
      if (!a.enabled && b.enabled) return 1;
      return a.name.compareTo(b.name);
    });
    return sortedList;
  }
  
  // Initialize event types stream for a user
  void initializeEventTypes(String userId) {
    _loading = true;
    notifyListeners();
    
    // Cancel any existing subscription
    _eventTypesSubscription?.cancel();
    
    // Subscribe to event types stream
    _eventTypesSubscription = _firestoreService.eventTypesStream(userId).listen(
      (eventTypes) {
        _eventTypes = eventTypes;
        _loading = false;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _loading = false;
        notifyListeners();
      }
    );
  }
  
  // Add a new event type
  Future<bool> addEventType({
    required String name,
    required String color,
    required String icon,
    required String userId,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final now = DateTime.now();
      final eventType = EventType(
        id: '', // Will be set by Firestore
        name: name,
        color: color,
        icon: icon,
        enabled: true,
        userId: userId,
        createdAt: now,
        updatedAt: now,
      );
      
      await _firestoreService.addEventType(eventType);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Update an event type
  Future<bool> updateEventType(String id, Map<String, dynamic> data) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _firestoreService.updateEventType(id, data);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Delete an event type
  Future<bool> deleteEventType(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _firestoreService.deleteEventType(id);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Toggle an event type's enabled status
  Future<bool> toggleEventType(String id) async {
    _error = null;
    notifyListeners();
    
    try {
      await _firestoreService.toggleEventType(id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Dispose
  @override
  void dispose() {
    _eventTypesSubscription?.cancel();
    super.dispose();
  }
}