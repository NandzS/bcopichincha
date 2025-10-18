import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';


typedef UserData = Map<String, dynamic>;

class BalanceService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final String _collectionPath = 'usuarios'; 

  double _balance = 0.0;
  
  StreamSubscription<DocumentSnapshot>? _balanceSubscription; 

  
  List<UserData> _allUsers = [];
  String? _currentUserId;

  double get balance => _balance;
  List<UserData> get allUsers => _allUsers;

 

  void initService() {
    _currentUserId = FirebaseService().currentUserId;
    if (_currentUserId == null) {
      print('Advertencia: BalanceService no puede inicializarse sin ID de usuario.');
      return;
    }

    _listenToUserBalance(_currentUserId!);
    _listenToAllUsers();
  }

  void _listenToAllUsers() {
    _firestore.collection(_collectionPath).snapshots().listen((snapshot) {
      _allUsers = snapshot.docs
          .where((doc) => doc.id != _currentUserId) 
          .map((doc) => {'id': doc.id, ...doc.data()}) 
          .toList();
      notifyListeners();
    });
  }

  void _listenToUserBalance(String userId) {
    
    _balanceSubscription?.cancel();

    
    _balanceSubscription = _firestore
        .collection(_collectionPath)
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data.containsKey('saldo')) {
          
          final newBalance = (data['saldo'] as num).toDouble(); 
          if (_balance != newBalance) {
            _balance = newBalance;
          }
        } else {
          _balance = 0.0;
          
          _firestore.collection(_collectionPath).doc(userId).set({'saldo': 0.0}, SetOptions(merge: true));
        }
      } else {
        
        _balance = 0.0;
        _firestore.collection(_collectionPath).doc(userId).set({'saldo': 0.0});
      }
      notifyListeners();
    }, onError: (error) {
      print("Error listening to balance: $error");
    });
  }

  
  void disposeService() {
    _balanceSubscription?.cancel();
    _balanceSubscription = null;
  }

  @override
  void dispose() {
    disposeService(); 
    super.dispose();
  }

  

  
  Future<String?> deposit(double amount) async {
    if (_currentUserId == null || amount <= 0) return "ID de usuario no disponible o monto inválido.";
    
    try {
      
      await _firestore.runTransaction((transaction) async {
        final userDocRef = _firestore.collection(_collectionPath).doc(_currentUserId);
        
        
        transaction.update(userDocRef, {'saldo': FieldValue.increment(amount)});
      });
      return null; 
    } catch (e) {
      print("Error al realizar el depósito: $e");
      return "Fallo en la transacción de depósito.";
    }
  }

 
  Future<String?> creditOwnAccount(double amount) async {
    return deposit(amount);
  }

  
  Future<String?> withdraw(double amount) async {
    if (_currentUserId == null || amount <= 0) return "Monto inválido.";
    
    try {
      await _firestore.runTransaction((transaction) async {
        final userDocRef = _firestore.collection(_collectionPath).doc(_currentUserId);
        final userSnapshot = await transaction.get(userDocRef);

        if (!userSnapshot.exists) {
          throw Exception("Documento de usuario no encontrado.");
        }

        
        final currentBalance = (userSnapshot.data()?['saldo'] as num?)?.toDouble() ?? 0.0;
        
        if (currentBalance < amount) {
         
          throw Exception("Saldo insuficiente."); 
        }

        final newBalance = currentBalance - amount;

        
        transaction.update(userDocRef, {'saldo': newBalance});
      });
      return null; // Éxito
    } catch (e) {
      
      if (e.toString().contains("Saldo insuficiente")) {
        return "Saldo insuficiente.";
      }
      print("Error al realizar el retiro: $e");
      return "Error de transacción: ${e.toString().split(':').last.trim()}";
    }
  }
  
  
  

  Future<String?> transferFunds(String recipientId, double amount) async {
    if (_currentUserId == null) return "Error: ID de emisor no disponible.";
    if (recipientId.isEmpty) return "Error: Debe seleccionar un destinatario.";
    if (amount <= 0) return "Error: El monto debe ser mayor a cero.";
    if (_currentUserId == recipientId) return "Error: No puede transferirse a sí mismo.";

    final senderRef = _firestore.collection(_collectionPath).doc(_currentUserId);
    final recipientRef = _firestore.collection(_collectionPath).doc(recipientId);

    try {
      await _firestore.runTransaction((transaction) async {
       
        final senderSnapshot = await transaction.get(senderRef);
        final currentSenderBalance = (senderSnapshot.data()?['saldo'] as num?)?.toDouble() ?? 0.0;

        
        if (currentSenderBalance < amount) {
          throw Exception("Saldo insuficiente durante la transacción.");
        }

        final recipientSnapshot = await transaction.get(recipientRef);
        final currentRecipientBalance = (recipientSnapshot.data()?['saldo'] as num?)?.toDouble() ?? 0.0;

        
        transaction.update(senderRef, {'saldo': currentSenderBalance - amount});
        transaction.update(recipientRef, {'saldo': currentRecipientBalance + amount});
      });

      return null; 
    } catch (e) {
      print("Error en la transacción de transferencia: $e");
      
      return "Error de transacción: ${e.toString().contains("Saldo insuficiente") ? "Saldo insuficiente." : "Fallo desconocido."}"; 
    }
  }
}