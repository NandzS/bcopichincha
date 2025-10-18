import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FirebaseService {
 
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance; 

  String? get currentUserId => _auth.currentUser?.uid;
  
  
  Future<void> initialize(String? customToken) async {
    if (_auth.currentUser == null) {
      if (customToken != null && customToken.isNotEmpty) {
        try {
          await _auth.signInWithCustomToken(customToken);
          print("Firebase Auth: Signed in with custom token.");
        } catch (e) {
          print("Firebase Auth Error: Failed to sign in with custom token: $e");
          
          await _auth.signInAnonymously();
          print("Firebase Auth: Signed in anonymously.");
        }
      } else {
        
        await _auth.signInAnonymously();
        print("Firebase Auth: Signed in anonymously.");
      }
    }
  }

 


Future<String> getNombreCompleto(String email) async {
    final query = await _db.collection('usuarios').where('email', isEqualTo: email).get();
    if (query.docs.isNotEmpty) {
      return query.docs.first['nombre'] ?? '';
    }
    return '';
  }
  
  
  Future<String?> registrar(String email, String password, String nombre) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      
      await _db.collection('usuarios').doc(cred.user!.uid).set({
        'nombre': nombre,
        'email': email,
        'saldo': 0.0, 
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

 
  Stream<User?> get usuario => _auth.authStateChanges();

  
  Future<void> logout() async => await _auth.signOut();
}