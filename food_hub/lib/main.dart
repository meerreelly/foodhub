import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/firebase/firebase_env_options.dart';
import 'core/firebase/firebase_status.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  var firebaseReady = false;
  try {
    await Firebase.initializeApp(options: FirebaseEnvOptions.currentPlatform);
    firebaseReady = true;
  } catch (_) {
    debugPrint('Firebase initialization failed. Running app without Firebase.');
    firebaseReady = false;
  }

  runApp(
    ProviderScope(
      overrides: [firebaseReadyProvider.overrideWithValue(firebaseReady)],
      child: const FoodHubApp(),
    ),
  );
}
