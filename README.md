# Sales Online App

Sales Online App is a Flutter mobile application for an online marketplace system. The app supports Buyer and Seller flows, including authentication, marketplace browsing, product listing, cart, checkout, shop management, real-time chat, push notifications, and user support requests.

The backend business logic is handled by a Spring Boot REST API, with PostgreSQL as the core relational database. Firebase is used for Authentication, Google Sign-In, Firebase Storage, Firestore real-time chat, and Firebase Cloud Messaging.

## Tech Stack

- Flutter / Dart
- Firebase Authentication
- Google Sign-In
- Firebase Storage
- Firebase Firestore
- Firebase Cloud Messaging
- Dio HTTP Client
- Shared Preferences
- Spring Boot REST API
- PostgreSQL

## Main Features

### Authentication

- Sign in with email and password through Firebase Authentication.
- Register a new user account through Firebase Authentication.
- Sign in or register with Google through Firebase Authentication and Google Sign-In.
- After Firebase authentication succeeds, the app syncs the user to the backend through `POST /api/users/sync`.
- Local login session is stored with `SharedPreferences`.

### Marketplace

- Display product categories and product lists.
- Fetch marketplace data from the backend through `DioClient`.
- Products belong to specific shops, matching the multi-seller marketplace model.
- Support search and filtering by category or product line.

### Product Details

- Display product images, price, description, stock quantity, and shop information.
- Allow buyers to view the seller shop profile.
- Support navigation to chat with the shop owner.
- Prevent adding out-of-stock products to the cart.

### Cart

- Allow buyers to manage selected products before checkout.
- Group cart items by shop.
- Support quantity update and item removal.
- Keep cart state locally before creating an order.

### Checkout And Payment

- Allow buyers to review order summary, delivery address, and payment method.
- Support COD flow.
- Payment gateway integration is expected through backend APIs such as MoMo or VNPay.
- Backend updates payment status through webhook/IPN callbacks.

### Seller Center

- Allow users to become sellers and manage their shop.
- Seller can create and manage products.
- Product images are expected to be uploaded to Firebase Storage.
- Backend stores product image URLs and shop/product data.
- Shop approval or locking is managed by Admin.

### Real-Time Chat

- Buyer and Seller chat is expected to use Firebase Firestore.
- Messages should update in real time without manual refresh.
- Chat rooms are expected to be mapped by buyer and shop identity.

### Support Requests

- Users can submit support tickets to Admin.
- Backend stores support request status and admin replies.
- Admin Portal handles support ticket review and response.

### Push Notifications

- Firebase Cloud Messaging is used for mobile push notifications.
- Backend and scheduler can send immediate or scheduled notifications.

## System Architecture

```text
Flutter Mobile App
  -> Firebase Auth / Google Sign-In
  -> Firebase UID
  -> Spring Boot REST API /api/users/sync
  -> PostgreSQL user table

Flutter Mobile App
  -> DioClient
  -> Spring Boot REST API
  -> PostgreSQL core data

Flutter Mobile App
  -> Firebase Storage
  -> Product images / avatars / shop logos

Flutter Mobile App
  -> Firebase Firestore
  -> Real-time chat

Spring Boot Scheduler
  -> PostgreSQL pending notification records
  -> Firebase Cloud Messaging
```

## Folder Structure

```text
sales_online_app/
├── android/                  # Native Android project
├── ios/                      # Native iOS project
├── lib/
│   ├── core/
│   │   ├── config/           # App-level configuration and repository factory
│   │   ├── constants/        # Shared app styles, colors, spacing, radius, text styles
│   │   ├── network/          # ApiConfig and DioClient
│   │   ├── theme/            # AppTheme and ThemeProvider
│   │   ├── utils/            # Shared utilities
│   │   └── widgets/          # Reusable core widgets
│   ├── data/
│   │   ├── models/           # Data models
│   │   ├── repositories/     # Repository interfaces and implementations
│   │   └── services/         # API, Firebase, and local storage services
│   ├── logic/
│   │   ├── auth/             # AuthController and auth state
│   │   ├── buyer/            # Buyer business logic
│   │   └── seller/           # Seller business logic
│   ├── ui/
│   │   ├── buyer/            # Buyer screens and widgets
│   │   ├── seller/           # Seller screens and widgets
│   │   └── shared/           # Shared screens such as auth, profile, main wrapper
│   ├── firebase_options.dart # Local Firebase config, ignored or generated in CI if needed
│   └── main.dart             # App entry point
├── test/                     # Widget and unit tests
├── pubspec.yaml              # Dependencies and Flutter configuration
└── README.md
```

## Core Project Rules

### API Rules

- Use `DioClient` from `lib/core/network/dio_client.dart` for backend API calls.
- Do not create random Dio instances unless there is a clear reason.
- Backend base URL is managed by `ApiConfig`.
- Authentication flow must follow this order:
  - Firebase Auth verifies credentials.
  - App receives Firebase UID.
  - App calls `POST /api/users/sync`.
  - Backend stores or updates user data in PostgreSQL.

### Firebase Rules

- `firebase_options.dart` is required locally for Firebase initialization.
- If `firebase_options.dart` is ignored from Git, CI must generate it from GitHub Actions secrets before `flutter analyze`.
- Never commit Firebase Admin SDK service account keys.
- Never commit `.env` files containing backend secrets.
- For Android Google Sign-In, Firebase Console must contain the correct package name and SHA-1/SHA-256 fingerprints.

### Frontend Rules

- Use shared styles from `lib/core/constants/app_styles.dart`.
- Do not edit `app_styles.dart` casually.
- If a screen needs small spacing or color adjustments, use `.copyWith()` or local calculations inside the current file.
- Do not hardcode random colors, font sizes, padding, or border radius.
- Keep UI compatible with Light Mode and Dark Mode.
- API-driven UI must handle loading, empty, success, and error states.

## Shared Style Guide

This project uses shared style constants to keep the UI consistent and maintainable.

### AppColors

Use `AppColors` instead of hardcoded colors.

Main colors:

- `AppColors.primary`
- `AppColors.whitePlaceholder`

Light Mode:

- `AppColors.backgroundLight`
- `AppColors.surfaceLight`
- `AppColors.textDark`
- `AppColors.textMutedLight`
- `AppColors.borderLight`

Dark Mode:

- `AppColors.backgroundDark`
- `AppColors.surfaceDark`
- `AppColors.textLight`
- `AppColors.textMutedDark`
- `AppColors.borderDark`

Example:

```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
final textColor = isDark ? AppColors.textLight : AppColors.textDark;
```

### AppSpacing

Use spacing constants instead of random numbers.

Common values:

- `AppSpacing.xs`
- `AppSpacing.sm`
- `AppSpacing.md`
- `AppSpacing.lg`
- `AppSpacing.xl`

Convenience widgets:

- `AppSpacing.h4`
- `AppSpacing.h8`
- `AppSpacing.h16`
- `AppSpacing.w4`
- `AppSpacing.w8`
- `AppSpacing.w16`

Example:

```dart
Padding(
  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
  child: child,
)
```

### AppRadius

Use shared border radius values:

- `AppRadius.small`
- `AppRadius.medium`
- `AppRadius.large`
- `AppRadius.xLarge`
- `AppRadius.circular`

Example:

```dart
RoundedRectangleBorder(
  borderRadius: AppRadius.xLarge,
)
```

### AppTextStyles

Use shared text styles:

- `AppTextStyles.display`
- `AppTextStyles.headingLarge`
- `AppTextStyles.headingMedium`
- `AppTextStyles.bodyLarge`
- `AppTextStyles.bodyMedium`
- `AppTextStyles.caption`
- `AppTextStyles.button`

Use `.copyWith()` for local overrides:

```dart
Text(
  'Create account',
  style: AppTextStyles.display.copyWith(
    color: textColor,
    fontWeight: FontWeight.w800,
  ),
)
```

## Commit Rules

Use short and clear commit messages.

Recommended format:

```text
<type>: <short description>
```

Recommended types:

- `feat`: new feature
- `fix`: bug fix
- `ui`: UI-only change
- `refactor`: code restructuring without behavior change
- `test`: test changes
- `docs`: documentation changes
- `chore`: tooling, config, dependency, or cleanup changes

Examples:

```text
feat: add Firebase Google sign-in
fix: prevent register loading spinner from hanging
ui: update register screen spacing
docs: update project README
chore: add firebase options generation to CI
```

Commit message rules:

- Use English for consistency.
- Keep the first line short and specific.
- Avoid vague messages such as `update`, `fix bug`, or `change code`.
- One commit should focus on one logical change.

## Pull Request Checklist

Before opening a pull request:

- Run `flutter analyze`.
- Run `flutter test`.
- Check unused imports, unused methods, and unused variables.
- Confirm `firebase_options.dart` is handled correctly.
- Do not commit generated or local-only files such as:
  - `devtools_options.yaml`
  - build artifacts
  - local `.env` files
- Confirm UI uses `app_styles.dart` constants where possible.
- Confirm backend API calls go through `DioClient`.

## Run Project

Install dependencies:

```bash
flutter pub get
```

List connected devices:

```bash
flutter devices
```

Run on Android emulator or physical device:

```bash
flutter run
```

Run on a specific device:

```bash
flutter run -d <device_id>
```

## Firebase Notes

### Email And Password Auth

Firebase Console must enable:

```text
Authentication > Sign-in method > Email/Password
```

### Google Sign-In

Firebase Console must enable:

```text
Authentication > Sign-in method > Google
```

For Android, check:

- Android package name matches `applicationId`.
- Debug SHA-1 and SHA-256 fingerprints are added.
- `google-services.json` is downloaded again after adding fingerprints if native config is used.
- The testing device has Google Play Services available and updated.

Get debug SHA fingerprints:

```bash
cd android
./gradlew signingReport
```

On Windows PowerShell:

```powershell
cd android
.\gradlew signingReport
```

## Backend Notes

The main backend sync endpoint is:

```text
POST /api/users/sync
```

This endpoint is called after Firebase authentication succeeds.

Expected user sync payload:

```json
{
  "firebaseUid": "firebase-user-uid",
  "fullName": "User Name",
  "email": "user@example.com",
  "phone": "",
  "role": "BUYER"
}
```

## CI Notes

If `lib/firebase_options.dart` is not committed, GitHub Actions must generate it before running `flutter analyze`.

Example workflow step using a base64 secret:

```yaml
- name: Create firebase_options.dart
  shell: bash
  run: |
    echo "${{ secrets.FIREBASE_OPTIONS_DART_B64 }}" | base64 --decode > lib/firebase_options.dart
    test -s lib/firebase_options.dart
```

The step must run before:

```yaml
- name: Install dependencies
  run: flutter pub get

- name: Analyze code
  run: flutter analyze
```