// apps/merchant/lib/features/auth/auth_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core_models/core_models.dart';
import 'package:firebase_sdk/firebase_sdk.dart';

class AuthNotifier extends StateNotifier<AppUser?> {
  final Ref _ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  MerchantModel? activeMerchant;
  RiderModel? activeRider;

  AuthNotifier(this._ref) : super(null) {
    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        state = null;
        activeMerchant = null;
        activeRider = null;
      } else {
        await _resolveProfileRole(user);
      }
    });
  }

  /// Resolves authenticated profile role by querying Firestore merchants and riders collection
  Future<void> _resolveProfileRole(User user) async {
    final userRepo = _ref.read(userRepositoryProvider);
    final merchantRepo = _ref.read(merchantRepositoryProvider);
    
    // 1. Check if user is a Rider
    // For riders, the document UID matches Firebase Auth UID
    final riderDoc = await _firestore.collection('riders').doc(user.uid).get();
    if (riderDoc.exists) {
      activeRider = RiderModel.fromJson(riderDoc.data()!);
      state = AppUser(
        uid: user.uid,
        displayName: activeRider!.name,
        email: '',
        phone: activeRider!.phone,
        role: 'rider',
      );
      return;
    }

    // 2. Check if user is a Merchant
    final merchant = await merchantRepo.getMerchantById(user.uid);
    if (merchant != null) {
      activeMerchant = merchant;
      state = AppUser(
        uid: user.uid,
        displayName: merchant.ownerName,
        email: merchant.email,
        phone: merchant.phone,
        role: 'merchant',
      );
      return;
    }

    // 3. Fallback: Default to customer/new registration
    AppUser? appUser = await userRepo.getUserById(user.uid);
    if (appUser == null) {
      appUser = AppUser(
        uid: user.uid,
        displayName: user.displayName ?? 'New Owner',
        email: user.email ?? '',
        avatar: user.photoURL,
        role: 'merchant', // default onboarding role
      );
      await userRepo.createUserProfile(appUser);
    }
    state = appUser;
  }

  /// Google login simulator for merchants
  Future<void> signInWithGoogleMerchantMock() async {
    try {
      final credential = await _auth.signInAnonymously();
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName("Alok Gupta");
        await _resolveProfileRole(user);
      }
    } catch (e) {
      print("❌ Merchant Auth Error: $e");
    }
  }

  /// Phone OTP login simulator for riders (Rule 9 spec phone auth override)
  Future<void> signInWithPhoneRiderMock(String phone, String inviteCode) async {
    try {
      // In production, we run verifyPhoneNumber. In mock testing, we verify in Firestore
      final riderSnapshot = await _firestore
          .collection('riders')
          .where('phone', isEqualTo: phone)
          .where('inviteCode', isEqualTo: inviteCode)
          .get();

      if (riderSnapshot.docs.isEmpty) {
        throw Exception("Invalid phone number or invite code combination.");
      }

      // Simulate Firebase Auth signing in
      final credential = await _auth.signInAnonymously();
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(riderSnapshot.docs.first.data()['name']);
        
        // Link rider UID in authentication to matching Firestore document
        final riderData = Map<String, dynamic>.from(riderSnapshot.docs.first.data());
        final oldId = riderData['uid'];
        riderData['uid'] = user.uid; // Update to actual UID
        
        // Re-write under authentic UID and clean up old draft
        await _firestore.collection('riders').doc(user.uid).set(riderData);
        if (oldId != user.uid) {
          await _firestore.collection('riders').doc(oldId).delete();
        }

        await _resolveProfileRole(user);
      }
    } catch (e) {
      print("❌ Rider Phone OTP Error: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = null;
    activeMerchant = null;
    activeRider = null;
  }

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
}

// RIVERPOD AUTH PROVIDERS
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AppUser?>((ref) {
  return AuthNotifier(ref);
});

final activeMerchantProvider = Provider<MerchantModel?>((ref) {
  return ref.watch(authNotifierProvider.notifier).activeMerchant;
});

final activeRiderProvider = Provider<RiderModel?>((ref) {
  return ref.watch(authNotifierProvider.notifier).activeRider;
});
