import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'notification_service.dart';

class AuthService extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? get user => _auth.currentUser;

  String? role;
  String? userName;

  bool isLoading = true;

  final _adminEmails = [
    'admin@mario.lv',
    'boss@mario.lv',
  ];

  AuthService() {
    _init();
  }

  // INIT
  Future<void> _init() async {
    _auth.authStateChanges().listen((user) async {

      // LOGIN BO‘LGAN
      if (user != null) {
        await _loadRoleForUser(user);
      }

      // LOGOUT
      else {
        role = null;
        userName = null;
        isLoading = false;
        notifyListeners();
      }
    });
  }

  // ROLE LOAD
  Future<void> _loadRoleForUser(User user) async {
    isLoading = true;
    notifyListeners();

    // ADMIN EMAIL TEKSHIRISH
    if (_adminEmails.contains(user.email?.toLowerCase())) {

      role = 'admin';

      userName =
          user.email?.split('@')[0] ?? 'Admin';

    } else {

      // FIRESTORE ROLE
      final firestoreRole =
      await _getRoleFromFirestore(user.uid);

      if (firestoreRole != null) {

        role =
            firestoreRole['role']?.toString() ??
                'worker';

        userName =
            firestoreRole['name']?.toString() ??
                user.email?.split('@')[0] ??
                '';

      } else {

        role = 'worker';

        userName =
            user.email?.split('@')[0] ?? '';
      }
    }

    // 🔥 FCM TOKEN SAQLASH
    await NotificationService.saveTokenForUser(
      user.uid,
    );

    isLoading = false;
    notifyListeners();
  }

  // FIRESTORE ROLE GET
  Future<Map<String, dynamic>?> _getRoleFromFirestore(
      String uid) async {

    // CACHE
    try {
      final cached = await _db
          .collection('users')
          .doc(uid)
          .get(
        const GetOptions(
          source: Source.cache,
        ),
      );

      if (cached.exists &&
          cached.data() != null) {

        return cached.data();
      }
    } catch (_) {}

    // SERVER
    try {
      final server = await _db
          .collection('users')
          .doc(uid)
          .get(
        const GetOptions(
          source: Source.server,
        ),
      )
          .timeout(
        const Duration(seconds: 5),
      );

      if (server.exists &&
          server.data() != null) {

        return server.data();
      }

    } catch (e) {
      print('Firestore error: $e');
    }

    return null;
  }

  // LOGIN
  Future<String?> login(
      String email,
      String password,
      ) async {

    try {

      isLoading = true;
      notifyListeners();

      final cred =
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _loadRoleForUser(
        cred.user!,
      );

      return null;

    } on FirebaseAuthException catch (e) {

      isLoading = false;
      notifyListeners();

      return _errorMessage(e.code);
    }
  }

  // LOGOUT
  Future<void> logout() async {

    isLoading = true;
    notifyListeners();

    await _auth.signOut();

    role = null;
    userName = null;

    isLoading = false;
    notifyListeners();
  }

  // ERROR MESSAGE
  String _errorMessage(String code) {

    switch (code) {

      case 'user-not-found':
        return 'Foydalanuvchi topilmadi';

      case 'wrong-password':
        return 'Parol noto‘g‘ri';

      case 'invalid-credential':
        return 'Email yoki parol noto‘g‘ri';

      case 'too-many-requests':
        return 'Keyinroq urinib ko‘ring';

      default:
        return 'Xatolik: $code';
    }
  }
}