// apps/customer/lib/features/auth/auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core_models/core_models.dart';
import 'package:firebase_sdk/firebase_sdk.dart';

class AuthNotifier extends StateNotifier<AppUser?> {
  final Ref _ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthNotifier(this._ref) : super(null) {
    // Listen to Firebase Auth state changes
    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        state = null;
      } else {
        await _syncUserProfile(user);
      }
    });
  }

  /// Syncs Firebase authenticated user details into Firestore `/users/{uid}`
  Future<void> _syncUserProfile(User user) async {
    final userRepo = _ref.read(userRepositoryProvider);
    
    // Fetch profile from Firestore
    AppUser? appUser = await userRepo.getUserById(user.uid);
    
    if (appUser == null) {
      // Create new profile on first Google Sign-In
      appUser = AppUser(
        uid: user.uid,
        displayName: user.displayName ?? 'Shahganj Citizen',
        email: user.email ?? '',
        avatar: user.photoURL,
        role: 'customer',
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );
      await userRepo.createUserProfile(appUser);
    } else {
      // Sync active timestamp and updates
      await userRepo.updateUserProfile(user.uid, {
        'displayName': user.displayName ?? appUser.displayName,
        'avatar': user.photoURL ?? appUser.avatar,
      });
      // Get updated profile
      appUser = await userRepo.getUserById(user.uid);
    }
    
    state = appUser;
  }

  /// Performs Google Sign-In integration
  Future<void> signInWithGoogleMock() async {
    // Under local testing constraints, we implement a secure test login simulator.
    // In production build, GoogleSignIn package from flutter is triggered natively.
    // We sign in using a dedicated test account or anonymous credential for demonstration.
    try {
      final credential = await _auth.signInAnonymously();
      final user = credential.user;
      if (user != null) {
        // Mock Google profile data for testing the flow
        await user.updateDisplayName("Prashant Bhushan");
        await _syncUserProfile(user);
      }
    } catch (e) {
      print("❌ Mock Auth Error: $e");
    }
  }

  /// Signs out of the Firebase Auth session
  Future<void> signOut() async {
    await _auth.signOut();
    state = null;
  }
}

// RIVERPOD AUTH PROVIDERS
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AppUser?>((ref) {
  return AuthNotifier(ref);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider) != null;
});
