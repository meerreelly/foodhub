import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

enum AppErrorType {
  firebaseNotConfigured,
  invalidCredentials,
  emailAlreadyInUse,
  weakPassword,
  network,
  requestFailed,
  mealNotFound,
  randomMealNotFound,
  unknown,
}

class AppException implements Exception {
  const AppException(this.type, {this.statusCode});

  final AppErrorType type;
  final int? statusCode;
}

String localizedError(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context);
  final type = switch (error) {
    AppException(:final type) => type,
    FirebaseAuthException(:final code) => _firebaseAuthType(code),
    _ => AppErrorType.unknown,
  };
  return switch (type) {
    AppErrorType.firebaseNotConfigured => l10n.t('firebaseNotConfigured'),
    AppErrorType.invalidCredentials => l10n.t('invalidCredentials'),
    AppErrorType.emailAlreadyInUse => l10n.t('emailAlreadyInUse'),
    AppErrorType.weakPassword => l10n.t('weakPassword'),
    AppErrorType.network => l10n.t('networkError'),
    AppErrorType.requestFailed => l10n.t('requestFailed'),
    AppErrorType.mealNotFound => l10n.t('mealNotFound'),
    AppErrorType.randomMealNotFound => l10n.t('randomMealNotFound'),
    AppErrorType.unknown => l10n.t('somethingWentWrong'),
  };
}

AppErrorType _firebaseAuthType(String code) {
  return switch (code) {
    'invalid-email' || 'invalid-credential' || 'wrong-password' || 'user-not-found' => AppErrorType.invalidCredentials,
    'email-already-in-use' => AppErrorType.emailAlreadyInUse,
    'weak-password' => AppErrorType.weakPassword,
    'network-request-failed' => AppErrorType.network,
    _ => AppErrorType.unknown,
  };
}
