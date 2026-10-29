import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/social_models.dart';
import 'firestore_paths.dart';
import 'push_service.dart';
import 'sync_service.dart';

class UsernameTakenException implements Exception {
  const UsernameTakenException();
  @override
  String toString() => 'That username is already taken';
}

/// Google sign-in + the user's public profile (users/{uid})
class AuthService extends GetxService {
  AuthService({required this.firebaseReady});

  static AuthService get to => Get.find<AuthService>();

  /// False when Firebase failed to initialize (e.g. unsupported platform);
  /// the app then runs in offline-only mode.
  final bool firebaseReady;

  final Rx<User?> user = Rx<User?>(null);
  final Rx<AppUser?> profile = Rx<AppUser?>(null);
  final RxBool profileLoaded = false.obs;

  /// Allowed: 3-20 chars, lowercase letters, digits, underscore and dot
  static final RegExp usernamePattern = RegExp(r'^[a-z0-9_.]{3,20}$');

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _fs => FirebaseFirestore.instance;

  StreamSubscription? _authSub;
  StreamSubscription? _profileSub;
  bool _googleInitialized = false;

  bool get isSignedIn => user.value != null;
  String? get uid => user.value?.uid;

  @override
  void onInit() {
    super.onInit();
    if (!firebaseReady) {
      profileLoaded.value = true;
      return;
    }
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.onClose();
  }

  void _onAuthChanged(User? firebaseUser) {
    user.value = firebaseUser;
    _profileSub?.cancel();
    profile.value = null;

    if (firebaseUser == null) {
      profileLoaded.value = true;
      return;
    }

    profileLoaded.value = false;
    _profileSub = FsPaths.users
        .doc(firebaseUser.uid)
        .snapshots()
        .listen(
          (doc) {
            profile.value = doc.exists ? AppUser.fromDoc(doc) : null;
            profileLoaded.value = true;
          },
          onError: (Object e) {
            debugPrint('Profile listener error: $e');
            profileLoaded.value = true;
          },
        );
    PushService.instance.registerFor(firebaseUser.uid);
  }

  // MARK: - Sign in / out

  Future<void> signInWithGoogle() async {
    if (!firebaseReady) {
      throw Exception('Firebase is not configured on this platform');
    }
    final google = GoogleSignIn.instance;
    if (!_googleInitialized) {
      // serverClientId is read from google-services.json (default_web_client_id)
      await google.initialize();
      _googleInitialized = true;
    }

    final GoogleSignInAccount account;
    try {
      account = await google.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return; // user closed the sheet - not an error
      }
      if (e.code == GoogleSignInExceptionCode.clientConfigurationError ||
          e.code == GoogleSignInExceptionCode.providerConfigurationError) {
        throw Exception(
          'Google Sign-In is not configured. Enable the Google provider in '
          'Firebase Authentication, add this app\'s SHA-1 fingerprint and '
          're-download google-services.json.',
        );
      }
      rethrow;
    }

    final idToken = account.authentication.idToken;
    if (idToken == null) throw Exception('Google did not return an ID token');

    final result = await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
    final signedIn = result.user;
    if (signedIn == null) return;

    await FsPaths.users.doc(signedIn.uid).set({
      'displayName': signedIn.displayName ?? account.displayName ?? '',
      'photoUrl': signedIn.photoURL ?? account.photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> signOut() async {
    if (!firebaseReady) return;
    final currentUid = uid;
    if (currentUid != null) {
      await PushService.instance.unregisterFor(currentUid);
    }
    // Stop syncing and remove this account's data from the device
    if (Get.isRegistered<SyncService>()) await SyncService.to.onSignOut();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      debugPrint('Google sign out failed: $e');
    }
    await _auth.signOut();
  }

  // MARK: - Username

  static String normalizeUsername(String input) =>
      input.trim().replaceFirst(RegExp(r'^@'), '').toLowerCase();

  /// Claims a unique username. Uniqueness is enforced by usernames/{name}.
  Future<void> setUsername(String input) async {
    final currentUid = uid;
    if (currentUid == null) throw Exception('Not signed in');

    final name = normalizeUsername(input);
    if (!usernamePattern.hasMatch(name)) {
      throw Exception('Use 3-20 lowercase letters, numbers, "_" or "."');
    }

    final previous = profile.value?.username;
    await _fs.runTransaction((tx) async {
      final nameRef = FsPaths.usernames.doc(name);
      final snap = await tx.get(nameRef);
      if (snap.exists && snap.data()?['uid'] != currentUid) {
        throw const UsernameTakenException();
      }
      if (previous != null && previous.isNotEmpty && previous != name) {
        tx.delete(FsPaths.usernames.doc(previous));
      }
      if (!snap.exists) tx.set(nameRef, {'uid': currentUid});
      tx.set(FsPaths.users.doc(currentUid), {
        'username': name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }
}
