import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../domain/app_user.dart';

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthController {
  const AuthController(this._repository);

  final AuthRepository _repository;

  Future<void> signIn(String email, String password) => _repository.signIn(email, password);
  Future<void> register(String email, String password) => _repository.register(email, password);
  Future<void> resetPassword(String email) => _repository.resetPassword(email);
  Future<void> signOut() => _repository.signOut();
}
