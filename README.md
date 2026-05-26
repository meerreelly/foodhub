# FoodHub

FoodHub is a Flutter recipe search and meal planning app. It uses TheMealDB for public recipe data and Firebase for authentication, favorites, custom recipes, image uploads, and weekly meal plans.

## Features

- Firebase Auth: sign up, sign in, sign out, password reset.
- Home screen with categories, random recipe of the day, and search by name or ingredient.
- Recipe details with ingredients, measures, instructions, YouTube link, and Hero image animation.
- Favorites saved per user in Firestore with real-time updates.
- Custom recipe form with validation, camera/gallery image picker, and Firebase Storage upload.
- Weekly meal planner using favorites.
- SharedPreferences for theme, language, and local app settings.
- Localization: Ukrainian, English, Polish.
- Material 3 UI with restrained liquid glass-style panels.
- Unit and widget tests.

## Architecture

The app follows a feature-first structure with clean layering:

- `core/` contains constants, theme, router, Firebase status, and localization.
- `features/*/domain` contains models and repository interfaces.
- `features/*/data` contains API, Firebase, SQLite, and sync repository implementations.
- `features/*/presentation` contains screens, widgets, and Riverpod providers.

State management is handled with Riverpod. Navigation is handled with GoRouter.

## Public APIs

TheMealDB endpoints used:

- `GET /search.php?s={meal_name}`
- `GET /filter.php?i={ingredient}`
- `GET /categories.php`
- `GET /lookup.php?i={id}`
- `GET /random.php`
- `GET /filter.php?c={category}`

Write operations are implemented through Firebase because TheMealDB is read-only.

## Firebase Setup

The code expects real Firebase for authentication. User-owned data is written to SQLite first and synchronized with Firebase when a signed-in user and Firebase configuration are available.

For real Firebase:

1. Create a Firebase project.
2. Enable Email/Password Authentication.
3. Create Firestore Database.
4. Enable Firebase Storage.
5. Install FlutterFire CLI if needed:

```bash
dart pub global activate flutterfire_cli
```

6. Create `.env` from `.env.example` and keep external service configuration there.
7. Configure Android and iOS:

```bash
flutterfire configure
```

The current implementation initializes Firebase from `.env`:

- `FIREBASE_API_KEY`
- `FIREBASE_APP_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_AUTH_DOMAIN`
- `FIREBASE_STORAGE_BUCKET`
- `FIREBASE_IOS_BUNDLE_ID`

These are client configuration values, not private admin secrets. Do not put service account keys or private tokens in the Flutter app.

Suggested Firestore shape:

- `users/{uid}/favorites/{mealId}`
- `users/{uid}/custom_recipes/{recipeId}`
- `users/{uid}/meal_plan/{day-slot}`

Rules should restrict each user to their own `users/{uid}` subtree.

## Run

```bash
flutter pub get
flutter run
```

Android:

```bash
flutter run -d android
```

iOS:

```bash
flutter run -d ios
```

iOS builds require macOS/Xcode.

## Quality Checks

```bash
flutter analyze
flutter test
```

Current test coverage includes:

- 5 unit tests for recipe/category parsing.
- 3 widget tests for recipe card rendering, add recipe validation, and Home search behavior.

## Notes

- Without real Firebase config, authentication actions return a configuration error.
- SQLite stores favorites, custom recipes, and meal plan entries locally with sync status metadata.
- Camera/gallery permissions are configured for Android and iOS.
- Network images in widget tests are not fetched by Flutter test; tests assert UI behavior instead of real image loading.
