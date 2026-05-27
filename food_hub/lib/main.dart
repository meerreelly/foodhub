import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'app.dart';
import 'core/firebase/firebase_env_options.dart';
import 'core/firebase/firebase_status.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
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
    LiquidGlassWidgets.wrap(
      child: ProviderScope(
        overrides: [firebaseReadyProvider.overrideWithValue(firebaseReady)],
        child: const FoodHubApp(),
      ),
    ),
  );
}
