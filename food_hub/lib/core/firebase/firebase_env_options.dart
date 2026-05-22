import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../config/env.dart';

class FirebaseEnvOptions {
  const FirebaseEnvOptions._();

  static FirebaseOptions get currentPlatform {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => FirebaseOptions(
          apiKey: Env.firebaseApiKey,
          appId: Env.firebaseAppId,
          messagingSenderId: Env.firebaseMessagingSenderId,
          projectId: Env.firebaseProjectId,
          authDomain: Env.firebaseAuthDomain.isEmpty ? null : Env.firebaseAuthDomain,
          storageBucket: Env.firebaseStorageBucket.isEmpty ? null : Env.firebaseStorageBucket,
        ),
      TargetPlatform.iOS => FirebaseOptions(
          apiKey: Env.firebaseApiKey,
          appId: Env.firebaseAppId,
          messagingSenderId: Env.firebaseMessagingSenderId,
          projectId: Env.firebaseProjectId,
          authDomain: Env.firebaseAuthDomain.isEmpty ? null : Env.firebaseAuthDomain,
          storageBucket: Env.firebaseStorageBucket.isEmpty ? null : Env.firebaseStorageBucket,
          iosBundleId: Env.firebaseIosBundleId.isEmpty ? null : Env.firebaseIosBundleId,
        ),
      _ => FirebaseOptions(
          apiKey: Env.firebaseApiKey,
          appId: Env.firebaseAppId,
          messagingSenderId: Env.firebaseMessagingSenderId,
          projectId: Env.firebaseProjectId,
          authDomain: Env.firebaseAuthDomain.isEmpty ? null : Env.firebaseAuthDomain,
          storageBucket: Env.firebaseStorageBucket.isEmpty ? null : Env.firebaseStorageBucket,
        ),
    };
  }
}
