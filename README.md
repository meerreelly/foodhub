# FoodHub

> Premium recipe search and meal planning app. Discover meals from TheMealDB, save favorites, create your own recipes with photos, and sync personal cooking data through Firebase.

Built with **Flutter · Dart 3.12+ · Material 3 · Riverpod · GoRouter · Firebase Auth + Firestore + Storage · TheMealDB API · SQLite**.

---

## Опис

FoodHub — мобільний застосунок для пошуку рецептів, збереження улюблених страв і планування меню на тиждень. Користувач реєструється через Firebase Auth, переглядає рецепти з TheMealDB, додає favorites, створює власні рецепти з фото та синхронізує персональні дані через Firebase. Локальна SQLite-база тримає дані доступними одразу й доганяє sync, коли Firebase доступний.

### Ключові фічі

- **Auth** — email/password sign up · sign in · sign out · password reset; protected routes через GoRouter `redirect`.
- **Home** — категорії, random recipe of the day, пошук страв за назвою або інгредієнтом, швидкий перехід до категорій.
- **Recipe Details** — Hero image animation, інгредієнти + міри, покрокова інструкція, відкриття YouTube-рецепта через `url_launcher`, додавання в favorites.
- **Favorites** — збереження улюблених рецептів per-user, Firestore real-time updates, локальна SQLite-копія з sync status.
- **My Recipes** — CRUD власних рецептів: title, category, ingredients, steps, image picker з камери або галереї, upload фото у Firebase Storage.
- **Custom Recipe Details** — перегляд власного рецепта, редагування, видалення, підтримка локального фото до завершення sync.
- **Meal Planner** — тижневий план харчування на базі favorites, збереження слотів у SQLite + Firestore.
- **Profile / Account** — профіль користувача, email, навігація до account/settings, sign out.
- **Settings** — Dark / Light / System тема, мова EN / UK / PL, миттєве збереження налаштувань у SharedPreferences.
- **Cloud sync** — favorites, custom recipes і meal plan живуть у Firestore під `users/{uid}`; зображення власних рецептів зберігаються у Firebase Storage.
- **Offline-first storage** — SQLite зберігає favorites, custom recipes і meal plan локально; pending-зміни синхронізуються при наявності Firebase-сесії.
- **Локалізація** — 3 мови через Flutter gen-l10n.

### Технології

- **State:** Riverpod (`Provider`, `FutureProvider`, `StreamProvider`, controllers).
- **Routing:** GoRouter з protected routes і `ShellRoute` для основної навігації.
- **HTTP:** `http` client + TheMealDB public API.
- **Firebase:** `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`.
- **Local storage:** `sqflite` для offline-first user data, `shared_preferences` для theme/language.
- **Config:** `flutter_dotenv` + `.env.example`.
- **UI:** Material 3, `google_fonts`, `cached_network_image`, `liquid_glass_widgets`, `image_picker`.
- **Misc:** `url_launcher`, `uuid`, `intl`.

### Архітектура

**Feature First + Clean-ish layering.** Кожна фіча винесена в окремий модуль, а shared-логіка лежить у `core/` і `features/shared/`. Domain-шар містить моделі й контракти, data-шар працює з API/Firebase/SQLite, presentation-шар відповідає за UI та Riverpod providers.

```
food_hub/
└── lib/
    ├── main.dart                 <- dotenv + Firebase init + ProviderScope
    ├── app.dart                  <- MaterialApp.router
    ├── core/                     <- config, router, theme, Firebase status, SQLite, l10n
    └── features/
        ├── auth/                 <- Firebase Auth + login/register/reset screens
        ├── favorites/            <- Firestore/SQLite favorites
        ├── home/                 <- Home, categories, category recipes
        ├── meal_plan/            <- Weekly planner
        ├── meals/                <- TheMealDB data source, models, details screen
        ├── profile/              <- Profile + account screens
        ├── recipes/              <- Custom recipes CRUD + Storage upload
        ├── settings/             <- Theme/language settings
        ├── shared/               <- Header, cards, async view, glass widgets
        └── shell/                <- App shell navigation
```

---

## Вигляд додатку

<p>
  <img src="docs/screenshots/photo_2026-05-28%2021.34.32.jpeg" width="24%" />
  <img src="docs/screenshots/photo_2026-05-28%2021.34.36.jpeg" width="24%" />
  <img src="docs/screenshots/photo_2026-05-28%2021.34.38.jpeg" width="24%" />
  <img src="docs/screenshots/photo_2026-05-28%2021.34.41.jpeg" width="24%" />
  <img src="docs/screenshots/photo_2026-05-28%2021.34.44.jpeg" width="24%" />
  <img src="docs/screenshots/photo_2026-05-28%2021.34.46.jpeg" width="24%" />
  <img src="docs/screenshots/photo_2026-05-28%2021.34.49.jpeg" width="24%" />
  <img src="docs/screenshots/photo_2026-05-28%2021.34.52.jpeg" width="24%" />
</p>

---

## Запуск

### Передумови

- Flutter SDK, сумісний з **Dart 3.12+** (`flutter --version`)
- Android Studio або Xcode
- Firebase-проєкт
- Увімкнені Firebase Auth, Firestore і Storage

### 1. Клон і залежності

```bash
git clone <this-repo>
cd foodhub/food_hub
flutter pub get
flutter gen-l10n
```

### 2. Environment

> **`food_hub/.env` НЕ комітиться**. У репозиторії є тільки `food_hub/.env.example`.

Створи локальний `.env`:

```bash
cp .env.example .env
```

Заповни значення:

```env
MEALDB_BASE_URL=https://www.themealdb.com/api/json/v1/1
FIREBASE_API_KEY=
FIREBASE_APP_ID=
FIREBASE_MESSAGING_SENDER_ID=
FIREBASE_PROJECT_ID=
FIREBASE_AUTH_DOMAIN=
FIREBASE_STORAGE_BUCKET=
FIREBASE_IOS_BUNDLE_ID=
```

Firebase client config — це не admin secrets, але приватні service account keys у Flutter app додавати не можна.

### 3. Firebase

Згенеруй platform-конфіг:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

У Firebase Console:

1. **Authentication -> Sign-in method** -> увімкни **Email/Password**.
2. **Firestore Database** -> Create database.
3. **Storage** -> Get started.
4. Перевір, що `.env` містить config саме твого Firebase-проєкту.

### 4. Firestore Rules

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

Кожен користувач має доступ тільки до власного `users/{uid}` піддерева.

### 5. Storage Rules

```js
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{uid}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

### 6. Firestore структура

```text
users/{uid}
├── favorites/{mealId}
├── custom_recipes/{recipeId}
└── meal_plan/{day-slot}
```

### 7. Permissions

Уже додано в проект — це для довідки.

#### Android — [AndroidManifest.xml](food_hub/android/app/src/main/AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
```

#### iOS — [Info.plist](food_hub/ios/Runner/Info.plist)

```xml
<key>NSCameraUsageDescription</key>
<string>FoodHub uses the camera to add photos to your own recipes.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>FoodHub uses the photo library to pick recipe photos.</string>
```

### 8. Команди

```bash
# Розробка
flutter run                       # debug build
flutter analyze                   # лінтер
flutter test                      # тести
flutter gen-l10n                  # перегенерувати локалізацію

# Релізні білди
flutter build apk --release       # Android APK
flutter build appbundle --release # Android App Bundle
flutter build ios --release       # iOS, потребує Xcode
flutter build web --release       # Web

# Очистка
flutter clean
flutter pub get
```

---

## Зовнішні API та посилання

### TheMealDB

- Base URL: `https://www.themealdb.com/api/json/v1/1`
- Public docs: [themealdb.com/api.php](https://www.themealdb.com/api.php)

Ендпоінти, які використовує застосунок:

- `GET /search.php?s={meal_name}` — пошук за назвою.
- `GET /filter.php?i={ingredient}` — пошук за інгредієнтом.
- `GET /categories.php` — список категорій.
- `GET /lookup.php?i={id}` — деталі рецепта.
- `GET /random.php` — random recipe of the day.
- `GET /filter.php?c={category}` — рецепти категорії.

Write operations реалізовані через Firebase, бо TheMealDB public API read-only.

---

## Тести та якість

```bash
flutter analyze
flutter test
```

Поточне покриття:

- Unit tests для парсингу meal/category моделей.
- Widget tests для recipe card, add recipe validation і home search behavior.

---

## GitHub Actions iOS IPA

Workflow `iOS IPA` збирає unsigned release IPA на macOS і завантажує artifact.

Перед запуском додай repository secret `DOTENV` з повним вмістом `food_hub/.env`. Якщо secret відсутній, build падає на ранньому етапі.

---

## Обмеження

- **TheMealDB public API** — read-only; власні рецепти, favorites і meal plan зберігаються в Firebase.
- **Firebase config required** — без валідного `.env` auth/sync/upload не працюватимуть.
- **Offline sync** — SQLite показує локальні pending-зміни, але cross-device sync з'являється тільки після успішного Firebase sync.
- **Storage rules** — якщо шлях Storage rules не збігається з шляхом upload у коді, фото власних рецептів не завантажаться.
- **Web build** — `image_picker` на web має платформні обмеження для камери/галереї.
