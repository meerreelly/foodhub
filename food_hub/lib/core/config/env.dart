import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  const Env._();

  static String get mealDbBaseUrl {
    final value = dotenv.env['MEALDB_BASE_URL'];
    if (value == null || value.isEmpty) throw const EnvException('MEALDB_BASE_URL is missing');
    return value;
  }

  static String get firebaseApiKey => _required('FIREBASE_API_KEY');
  static String get firebaseAppId => _required('FIREBASE_APP_ID');
  static String get firebaseMessagingSenderId => _required('FIREBASE_MESSAGING_SENDER_ID');
  static String get firebaseProjectId => _required('FIREBASE_PROJECT_ID');
  static String get firebaseAuthDomain => dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';
  static String get firebaseStorageBucket => dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  static String get firebaseIosBundleId => dotenv.env['FIREBASE_IOS_BUNDLE_ID'] ?? '';

  static String _required(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) throw EnvException('$key is missing');
    return value;
  }
}

class EnvException implements Exception {
  const EnvException(this.message);

  final String message;

  @override
  String toString() => message;
}
