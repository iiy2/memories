import 'package:flutter/material.dart';
import 'package:memory_flutter/models/user_model.dart';
import 'package:memory_flutter/services/auth_service.dart';
import 'package:memory_flutter/services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  UserModel? _user;
  bool _loading = false;
  String? _error;
  
  // Getters
  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _loading;
  String? get error => _error;
  
  // Constructor - initialize auth state
  AuthProvider() {
    // Listen to auth state changes
    _authService.userStream.listen((user) {
      _user = user;
      notifyListeners();
      
      // If user is newly authenticated, initialize default event types
      if (user != null) {
        _firestoreService.initializeDefaultEventTypes(user.uid);
      }
    });
  }
  
  // Sign in
  Future<bool> signIn(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _authService.signInWithEmailAndPassword(email, password);
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
  
  // Register
  Future<bool> register(String email, String password, String name) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _authService.registerWithEmailAndPassword(email, password, name);
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
  
  // Sign out
  Future<void> signOut() async {
    _loading = true;
    notifyListeners();
    
    try {
      await _authService.signOut();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  // Reset password
  Future<bool> resetPassword(String email) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _authService.resetPassword(email);
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
  
  // Update profile
  Future<bool> updateProfile({String? displayName, String? photoURL}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _authService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
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
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}