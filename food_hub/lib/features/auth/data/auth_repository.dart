import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/firebase/firebase_status.dart';
import '../domain/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(firebaseReady: ref.watch(firebaseReadyProvider));
});

class AuthRepository {
  AuthRepository({required this._firebaseReady});

  final bool _firebaseReady;

  Stream<AppUser?> authStateChanges() {
    if (_firebaseReady) {
      return FirebaseAuth.instance.authStateChanges().map(_mapUser);
    }
    return Stream.value(null);
  }

  AppUser? currentUser() {
    if (_firebaseReady) return _mapUser(FirebaseAuth.instance.currentUser);
    return null;
  }

  Future<void> signIn(String email, String password) async {
    _ensureFirebaseReady();
    if (_firebaseReady) {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    }
  }

  Future<void> register(String email, String password) async {
    _ensureFirebaseReady();
    if (_firebaseReady) {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    }
  }

  Future<void> resetPassword(String email) async {
    _ensureFirebaseReady();
    if (_firebaseReady) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    }
  }

  Future<void> signOut() async {
    _ensureFirebaseReady();
    if (_firebaseReady) {
      await FirebaseAuth.instance.signOut();
    }
  }

  AppUser? _mapUser(User? user) {
    if (user == null) return null;
    return AppUser(uid: user.uid, email: user.email ?? '');
  }

  void _ensureFirebaseReady() {
    if (!_firebaseReady) throw const FirebaseUnavailableException();
  }
}

class FirebaseUnavailableException extends AppException {
  const FirebaseUnavailableException() : super(AppErrorType.firebaseNotConfigured);
}
