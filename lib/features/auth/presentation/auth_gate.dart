import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/debt_reminder_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/services/auth_service.dart';
import '../../groups/presentation/group_list_screen.dart';
import 'login_screen.dart';
import 'username_setup_screen.dart';

/// Chooses between login, username setup and the main app
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final gate = Get.put(AuthGateController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationService.instance.requestPermission();
      await DebtReminderService.instance.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.to;
    return Obx(() {
      if (!auth.firebaseReady) return const GroupListScreen();

      if (!auth.isSignedIn) {
        return gate.skipped.value
            ? const GroupListScreen()
            : const LoginScreen();
      }

      if (!auth.profileLoaded.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      if (!(auth.profile.value?.hasUsername ?? false)) {
        return const UsernameSetupScreen();
      }

      return const GroupListScreen();
    });
  }
}
