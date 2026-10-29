import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'firestore_paths.dart';

/// Registers this device's FCM token on the user's profile so the
/// `pushOnNotification` Cloud Function can deliver pushes while the app is
/// closed. Foreground notifications are shown by SocialService instead.
class PushService {
  PushService._();
  static final PushService instance = PushService._();

  StreamSubscription<String>? _registeredSub;
  String? _token;

  /// Called when the user taps a push that opened / resumed the app
  void Function()? onOpenedFromPush;

  /// True when a tapped push launched the app from a terminated state
  bool launchedFromPush = false;

  bool _listening = false;

  Future<void> init() async {
    if (_listening) return;
    _listening = true;
    try {
      FirebaseMessaging.onMessageOpenedApp.listen(
        (_) => onOpenedFromPush?.call(),
      );
      launchedFromPush =
          await FirebaseMessaging.instance.getInitialMessage() != null;
    } catch (e) {
      debugPrint('FCM init failed: $e');
    }
  }

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      FsPaths.users.doc(uid);

  Future<void> registerFor(String uid) async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();

      // onRegistered fires with the token now and again whenever it rotates
      await _registeredSub?.cancel();
      _registeredSub = messaging.onRegistered.listen((token) {
        _token = token;
        _saveToken(uid, token);
      });
      await messaging.register();
    } catch (e) {
      // Push is best-effort: the in-app inbox still works without it
      debugPrint('FCM token registration failed: $e');
    }
  }

  Future<void> unregisterFor(String uid) async {
    await _registeredSub?.cancel();
    _registeredSub = null;
    try {
      final token = _token;
      if (token != null) {
        await _userRef(uid).update({
          'fcmTokens': FieldValue.arrayRemove([token]),
        });
      }
    } catch (e) {
      debugPrint('FCM token removal failed: $e');
    }
  }

  Future<void> _saveToken(String uid, String token) async {
    try {
      await _userRef(uid).set({
        'fcmTokens': FieldValue.arrayUnion([token]),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FCM token save failed: $e');
    }
  }
}
