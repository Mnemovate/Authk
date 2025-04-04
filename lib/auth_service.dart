import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; 

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService { 
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance; 

  User? get currentUser => firebaseAuth.currentUser; 

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges(); 

  Future<UserCredential> signIn({ 
    required String email, 
    required String password, 
  }) async { 
    return await firebaseAuth.signInWithEmailAndPassword( 
      email: email, 
      password: password,
    ); 
  } 

  Future<UserCredential> createAccount({ 
    required String email, 
    required String password, 
  }) async { 
    return await firebaseAuth.createUserWithEmailAndPassword( 
      email: email, 
      password: password,
    ); 
  } 

  Future<void> signOut() async {
    await firebaseAuth.signOut(); 
  }

  Future<void> updateUsername({ 
    required String username, 
  }) async { 
    await currentUser!.updateDisplayName (username); 
  }

  Future<void> resetPassword({ 
    required String email, 
  }) async { 
    await firebaseAuth.sendPasswordResetEmail(email: email); 
  }

  Future<void> deleteAccount({ 
    required String email, 
    required String password, 
  }) async { 
    AuthCredential credential = 
    EmailAuthProvider.credential(email: email, password: password); 

    await currentUser!.reauthenticateWithCredential(credential); 
    await currentUser!.delete(); 
    await firebaseAuth.signOut(); 
  }

  Future<void> resetPasswordFromCurrentPassword({ 
    required String currentPassword, 
    required String newPassword, 
    required String email, 
  }) async { 
    AuthCredential credential = EmailAuthProvider.credential (email: email, password: currentPassword); 
    await currentUser!.reauthenticateWithCredential (credential); 
    await currentUser!.updatePassword(newPassword);
  }


  // Phone Authentication (OTP)
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<UserCredential> signInWithOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    
    return await firebaseAuth.signInWithCredential(credential);
  }

  // Add this method to your AuthService class
Future<UserCredential> signInWithPhoneCredential(PhoneAuthCredential credential) async {
  return await firebaseAuth.signInWithCredential(credential);
}
}