import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Using a provider pattern instead of global ValueNotifier for better dependency injection
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() => _instance;
  
  AuthService._internal();
  
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  // Getters
  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  bool get isSignedIn => currentUser != null;
  
  // Auth methods with better error handling
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    notifyListeners();
  }
  
  Future<void> updateUsername({
    required String username,
  }) async {
    try {
      if (currentUser == null) {
        throw const AuthException(
          code: 'user-not-found',
          message: 'No user is currently signed in',
        );
      }
      await currentUser!.updateDisplayName(username);
      // Force refresh to update user data
      await currentUser!.reload();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    try {
      if (currentUser == null) {
        throw const AuthException(
          code: 'user-not-found',
          message: 'No user is currently signed in',
        );
      }
      
      // Re-authenticate user before deletion
      AuthCredential credential = EmailAuthProvider.credential(
        email: email, 
        password: password
      );
      
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.delete();
      await _firebaseAuth.signOut();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    try {
      if (currentUser == null) {
        throw const AuthException(
          code: 'user-not-found',
          message: 'No user is currently signed in',
        );
      }
      
      // Re-authenticate user before changing password
      AuthCredential credential = EmailAuthProvider.credential(
        email: email, 
        password: currentPassword
      );
      
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.updatePassword(newPassword);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Phone Authentication (OTP)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) {
          verificationCompleted(credential);
          notifyListeners();
        },
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  Future<UserCredential> signInWithOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      final result = await _firebaseAuth.signInWithCredential(credential);
      notifyListeners();
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  Future<UserCredential> signInWithPhoneCredential(
    PhoneAuthCredential credential
  ) async {
    try {
      final result = await _firebaseAuth.signInWithCredential(credential);
      notifyListeners();
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Helper to convert Firebase exceptions to our custom exceptions
  AuthException _handleAuthException(FirebaseAuthException e) {
    return AuthException(
      code: e.code,
      message: e.message ?? 'An authentication error occurred',
    );
  }
}

// Custom auth exception for better error handling
class AuthException implements Exception {
  final String code;
  final String message;
  
  const AuthException({
    required this.code,
    required this.message,
  });
  
  @override
  String toString() => 'AuthException: [$code] $message';
}

// Create a singleton instance that can be used throughout the app
final authService = AuthService();