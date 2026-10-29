import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/services/app_prefs.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'data/services/auth_service.dart';
import 'data/services/database_service.dart';
import 'data/services/push_service.dart';
import 'data/services/social_service.dart';
import 'data/services/sync_service.dart';
import 'features/social/presentation/notifications_screen.dart';
import 'features/splash/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await DatabaseService().isar;
  await AppPrefs.init();
  await NotificationService.instance.init();

  final firebaseReady = await _initFirebase();
  Get.put(AuthService(firebaseReady: firebaseReady), permanent: true);
  if (firebaseReady) {
    Get.put(SocialService(), permanent: true);
    Get.put(SyncService(), permanent: true);
    await PushService.instance.init();
  }

  _wireNotificationTaps(firebaseReady);
  runApp(const MyApp());
}

/// The app keeps working offline if Firebase can't start (e.g. on iOS
/// until GoogleService-Info.plist is added).
Future<bool> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return true;
  } catch (e) {
    debugPrint('Firebase unavailable, running offline: $e');
    return false;
  }
}

void _wireNotificationTaps(bool firebaseReady) {
  void openInbox() {
    // currentUser is restored at startup, before authStateChanges emits
    if (!firebaseReady || FirebaseAuth.instance.currentUser == null) return;
    // Wait for the first frame so GetMaterialApp's navigator exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.to(() => const NotificationsScreen());
    });
  }

  final notifications = NotificationService.instance;
  notifications.onTap = (payload) {
    if (payload == NotificationPayloads.social) openInbox();
  };
  final push = PushService.instance;
  push.onOpenedFromPush = openInbox;
  if (notifications.launchPayload == NotificationPayloads.social ||
      push.launchedFromPush) {
    openInbox();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart Split',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: AppPrefs.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
