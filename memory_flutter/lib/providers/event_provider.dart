import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memory_flutter/models/event.dart';
import 'package:memory_flutter/services/firestore_service.dart';

class EventProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Event> _events = [];
  bool _loading = false;
  String? _error;
  StreamSubscription<List<Event>>? _eventsSubscription;
  
  // Getters
  List<Event> get events => _events;
  bool get isLoading => _loading;
  String? get error => _error;
  
  // Get sorted events (most recent first)
  List<Event> get sortedEvents {
    final sortedList = List<Event>.from(_events);
    sortedList.sort((a, b) => b.date.compareTo(a.date));
    return sortedList;
  }
  
  // Filter events by search term and category
  List<Event> getFilteredEvents({String? searchTerm, String? category}) {
    return sortedEvents.where((event) {
      // Filter by search term
      if (searchTerm != null && searchTerm.isNotEmpty) {
        final searchLower = searchTerm.toLowerCase();
        if (!event.title.toLowerCase().contains(searchLower) &&
            !event.description.toLowerCase().contains(searchLower)) {
          return false;
        }
      }
      
      // Filter by category
      if (category != null && category != 'All' && event.category != category) {
        return false;
      }
      
      return true;
    }).toList();
  }
  
  // Initialize event stream for a user
  void initializeEvents(String userId) {
    _loading = true;
    notifyListeners();
    
    // Cancel any existing subscription
    _eventsSubscription?.cancel();
    
    // Subscribe to events stream
    _eventsSubscription = _firestoreService.eventsStream(userId).listen(
      (events) {
        _events = events;
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
  
  // Add a new event
  Future<bool> addEvent({
    required String title,
    required DateTime date,
    required String description,
    required String category,
    required String userId,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final now = DateTime.now();
      final event = Event(
        id: '', // Will be set by Firestore
        title: title,
        date: date,
        description: description,
        category: category,
        userId: userId,
        createdAt: now,
        updatedAt: now,
      );
      
      await _firestoreService.addEvent(event);
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
  
  // Update an event
  Future<bool> updateEvent(String id, Map<String, dynamic> data) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _firestoreService.updateEvent(id, data);
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
  
  // Delete an event
  Future<bool> deleteEvent(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _firestoreService.deleteEvent(id);
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
  
  // Get a single event
  Future<Event?> getEvent(String id) async {
    try {
      return await _firestoreService.getEvent(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
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
    _eventsSubscription?.cancel();
    super.dispose();
  }
}