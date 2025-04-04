import 'package:firebase_auth/firebase_auth.dart';
import 'package:memory_flutter/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Auth state changes stream
  Stream<UserModel?> get userStream {
    return _auth.authStateChanges().map((User? user) {
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    });
  }
  
  // Current user
  UserModel? get currentUser {
    final user = _auth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }
  
  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user != null ? UserModel.fromFirebaseUser(result.user!) : null;
    } catch (e) {
      rethrow;
    }
  }
  
  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(
    String email, 
    String password, 
    String displayName
  ) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // Update display name
      if (result.user != null) {
        await result.user!.updateDisplayName(displayName);
        // Reload user to get updated info
        await result.user!.reload();
        final updatedUser = _auth.currentUser;
        return updatedUser != null ? UserModel.fromFirebaseUser(updatedUser) : null;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
  
  // Update profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
      await user.reload();
    }
  }
}