# smart_expense_tracker

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase setup (friends, Google login, push)

The app works fully offline; these steps enable the online features.

1. **Authentication → Sign-in method → enable Google.**
2. **Project settings → Your apps → Android (`com.example.smart_expense_tracker`) → add SHA-1** of every keystore you build with. Debug keystore:
   `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android | grep SHA1`
3. **Download `google-services.json` again** and replace `android/app/google-services.json`
   (after steps 1–2 it contains the OAuth client Google Sign-In needs).
4. **Create a Firestore database**, then deploy rules (and the push function — needs the Blaze plan):
   ```sh
   npm i -g firebase-tools && firebase login
   (cd functions && npm install)
   firebase deploy --only firestore:rules,functions
   ```
   Without the function, friend/invite notifications still appear while the app is open.

iOS is not configured for Firebase yet (run `flutterfire configure`); on iOS the app runs in offline mode.
