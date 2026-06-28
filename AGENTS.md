# Micro-Society App — AGENTS.md

## Commands
- `flutter pub get` — install dependencies
- `flutter analyze` — must pass before any commit
- `flutter test` — runs smoke test at `test/widget_test.dart`
- `flutter run` — runs on Android only (other platforms removed)
- `firebase deploy --only firestore:rules` — push security rules to `society-app-1f904`

## Firebase
- **Project:** `society-app-1f904` (set in `.firebaserc`)
- **Android app:** package `com.microsociety.micro_society_app`
- **Initialization:** `lib/main.dart` calls `Firebase.initializeApp(options: DefaultFirebaseOptions.android)` — Android-only stub in `lib/firebase_options.dart` (keys are real, committed)
- **Services enabled:** Auth (Email/Password), Storage
- **Firestore:** Billing must be enabled before creating database (Spark free tier covers quota)
- **Rules:** `firestore.rules` at repo root, already deployed
- **Collections:** `users` (Doc ID = Auth UID), `flats`, `issues`, `events`

## Architecture
- **State:** Provider ^6.1.1 (`ChangeNotifier` in `lib/providers/`) + local `setState`
- **Services layer:** `lib/services/` (AuthService, FirestoreService, StorageService) — singletons via `Firebase.instance`
- **Models:** Each model has `fromMap()` + `toMap()` + `copyWith()`
- **Navigation:** Named routes defined in `lib/app.dart` — no `Navigator.pushNamed` with arguments pattern currently (all const routes)
- **Theme:** Material 3, Inter font, Vercel-inspired palette (`lib/config/theme.dart`)
- **Collection name constants:** `lib/config/app_config.dart`

## Key conventions
- No comments in code
- `const` constructors everywhere
- Null-safe, no `!` without guard
- `StreamSubscription` disposed in `dispose()`
- Auth state tracked via `AuthProvider` listening to `FirebaseAuth.authStateChanges()`
- Flat status filter: enum-like string constants (`'vacant'`, `'occupied'`, `'pending'`) with UI filter `'All'`

## Platform
- **Android only** — `ios/`, `web/`, `linux/`, `macos/`, `windows/` removed
- `minSdk = 23` in `android/app/build.gradle.kts`
- Google Services plugin at `android/app/build.gradle.kts:3` and classpath at `android/build.gradle.kts:6`

## Tests
- Single smoke test at `test/widget_test.dart` — fails without Firebase emulator/mock (widget tree references providers needing Firebase init)
