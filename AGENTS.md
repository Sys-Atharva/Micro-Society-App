# Micro-Society App — AGENTS.md

## Commands

- `flutter pub get` — install dependencies
- `flutter analyze` — must pass before any commit
- `flutter test` — runs smoke test at `test/widget_test.dart`
- `flutter run` — runs on Android only (other platforms removed)
- `firebase deploy --only firestore:rules` — push security rules to `society-app-1f904`

---

## Firebase

- **Project:** `society-app-1f904` (set in `.firebaserc`)
- **Android app:** package `com.microsociety.micro_society_app`
- **Initialization:** `lib/main.dart` calls `Firebase.initializeApp(options: DefaultFirebaseOptions.android)` — Android-only stub in `lib/firebase_options.dart` (keys are real, committed)
- **Services enabled:** Auth (Email/Password), Storage
- **Firestore:** Billing must be enabled before creating database (Spark free tier covers quota)
- **Rules:** `firestore.rules` at repo root, already deployed
- **Collections:** `users` (Doc ID = Auth **UID**), `flats`, `issues`, `events`
- **Composite indexes:** Defined in `firestore.indexes.json` for `events` (buildingCode + eventDate) and `issues` (buildingCode + createdAt DESC, tenantId + createdAt DESC)

---

## Architecture & Providers

- **State:** Provider ^6.1.1 (`ChangeNotifier` in `lib/providers/`) + local `setState`
- **Services layer:** `lib/services/` (`AuthService`, `FirestoreService`, `StorageService`) — access Firebase singletons via `FirebaseAuth.instance`, `FirebaseFirestore.instance`, `FirebaseStorage.instance`
- **Models:** Each model has `fromMap()` + `toMap()` + `copyWith()`
- **Collection name constants:** `lib/config/app_config.dart`
- **Utilities:** `lib/utils/building_code_generator.dart` — generates unique `BLDG-XXXX` building codes with Firestore uniqueness check.
- **Models detail:** `UserModel` includes nested `BankDetails` sub-model (`bankName`, `accountNumber`, `ifscCode`). `fromMap()` requires a second `uid`/`id` parameter.

### Key Provider Methods

- `FlatProvider.streamFlatsByBuilding(code)` — fetches vacant flats for tenant dropdown during onboarding.
- `FirestoreService.updateDocument('users', uid, {buildingCode, flatId})` — writes tenant building and flat data directly to the user profile.

---

## Theme & Styling

- Material 3 architecture with Inter font following the **Stitch design system** (`lib/config/theme.dart`)
- **Primary Accent:** `#**4648D4**` (indigo)
- **On-Surface:** `#**0B1C30**` (deep navy)
- **Surface Options:** `#**F8F9FF**` (base surface), `#**EFF4FF**` (surface-container-low)
- **Container Accent:** `#**131B2E**` (primary-container-dark)
- **Border Radius:** 12px for buttons and inputs, 16px for cards

---

## Auth & Routing Flows

### Navigation Architecture

- Named routes defined globally in `lib/app.dart`.
- Onboarding and transient screens accept `arguments` context via `Navigator.pushReplacementNamed`.
- Deep routing state verification happens during app initialization inside `SplashScreen._checkAuth()`.

### Owner Journey Map

``` Splash → Login/Signup → Role Selection (Owner) → Bank Details (onboarding) → Owner Dashboard

```

### Tenant Journey Map

``` Splash → Role Selection (Tenant) → Login/Signup → Building Code Setup → Waiting Room → Tenant Dashboard

```

### Complex Routing Triggers (`SplashScreen._checkAuth()`)

- **No Building Code Registered:** Routes directly to `/tenant/join`
- **Has Building Code, Pending Approval:** Routes directly to `/tenant/waiting`
- **Has Building Code & Approved:** Routes directly to `/tenant/dashboard`
- **Onboarding Edge Cases:** `/owner/bank-details` expects argument payloads: `{'onboarding': true}`

---

## Screens Checklist

| Screen | Core Architectural / UI Features |
| --- | --- |
| `SplashScreen` | Dark gradient backdrop, animated progress loading bar, glassmorphism overlays, auth-state routing. |
| `LoginScreen` | Floating glass card construction, background decorative blobs, navigates to splash for auth-state re-evaluation. |
| `RegisterScreen` | Glass card formatting, terms and conditions validation checkbox, built-in trust badges. |
| `RoleSelectionScreen` | Dual glass card layout options, physical haptic feedback integration, trust badges, fully scrollable interface wrapper. |
| `BankDetailsScreen` | Evaluates `onboarding` flag arguments, visual top progress tracker bar, compliance security badges, account type dropdown. |
| `OwnerDashboard` | Delegates to `OwnerShell` with glass-morphic transparent `AppBar`, 4-tab `IndexedStack` (Home, Flats, Events, Issues), custom bottom nav. |
| `OwnerProfileScreen` | Initials avatar, stats grid (managed units, active issues), building code display with copy, personal details list. |
| `EditProfileScreen` | Editable name/phone/society/address fields, read-only email, save via `UserProvider`. |
| `SettingsScreen` | Account actions card (edit profile, privacy, logout), notifications toggle, app info. |
| `PrivacyScreen` | Static privacy/security info sections. |
| `ManageFlatsScreen` | Standalone flat management with filter chips (All/Vacant/Occupied/Pending), add/delete via dialog/dismissible. |
| `EventDetailScreen` | Event detail view with status badge, date/time/location, description. |
| `JoinBuildingScreen` | Interactive real-time building code validator, hooks into dynamic vacant flat choices sourced from Firestore. |
| `WaitingRoomScreen` | Focused Hero graphical zone, persistent custom pulsing animation, user action triggers for manual notifications/data edits. |
| `TenantDashboard` | Welcome grid with Report Issue and Payments cards. |
| `TenantIssuesScreen` | Tenant issue list with add dialog, status badges. |
| `PaymentsScreen` | Payment placeholder with "coming soon" message, displays owner bank details if available. |

### Owner Tab Screens (`OwnerShell` via `IndexedStack`)

| Tab | File | Features |
| --- | --- | --- |
| `HomeTab` | `tabs/home_tab.dart` | Stats grid (total/occupied/vacant flats, open issues), upcoming events list, recent issues list. |
| `FlatsTab` | `tabs/flats_tab.dart` | Flat list with filter chips, add flat dialog, delete via popup menu. |
| `EventsTab` | `tabs/events_tab.dart` | Event list with add dialog (date/time pickers), status update (completed/cancelled/upcoming), delete. |
| `IssuesTab` | `tabs/issues_tab.dart` | Issue list with add dialog (priority selector), status update (in_progress/resolved/open), delete. |

---

## UI Components & Shared Widgets

- **`CustomTextField`**: Extended layout support adding `helperText` fields and structural `textCapitalization` control rules.
- **`LoadingButton`**: Standard processing button with newly supported optional trailing asset/icon slotting (`trailingIcon`).
- **`StatusBadge`**: Color-coded status pill widget supporting flat statuses (`vacant`, `occupied`, `pending`), issue statuses (`open`, `in_progress`, `resolved`), and event statuses (`upcoming`, `completed`, `cancelled`).

---

## Key Development Conventions

- **No comments allowed in the codebase.**
- Use `const` constructors aggressively everywhere possible.
- Strictly null-safe: **never** pass an exclamation bang operator (`!`) without a direct validation guard right before it.
- Every `StreamSubscription` must be explicitly cancelled and cleaned up within its corresponding stateful widget `dispose()` lifecycle.
- Authentic structural session updates are handled contextually via `AuthProvider` listening down to streams from `FirebaseAuth.authStateChanges()`.
- Flat validation parameters use fixed string enum matches (`'vacant'`, `'occupied'`, `'pending'`) handled by the layout layer engine supporting a global `'All'` selector rule.
- `EventProvider.checkAndAutoCompleteEvents()` auto-marks past `upcoming` events as `completed`.

---

## Target Platform Requirements

- **Android Only:** All support files and compilation directories for `ios/`, `web/`, `linux/`, `macos/`, `windows/` are fully removed from the workspace.
- Minimum **API** platform target constraint: `minSdk = flutter.minSdkVersion` (Flutter default, currently **21**) in `android/app/build.gradle.kts`. Override to 23 if needed.
- Safe Google Services engine integration: plugin applied at line 3 of `android/app/build.gradle.kts` and classpath dependency at line 7 of `android/build.gradle.kts`.

---

## Test Management

- Single foundational sanity run mapping test located inside `test/widget_test.dart`.
- *Note:* This test suite will fail locally/on CI without an active instance of the Firebase Emulator suite or proper provider mocking due to explicit widget tree structural dependencies expecting instant root connection allocations.