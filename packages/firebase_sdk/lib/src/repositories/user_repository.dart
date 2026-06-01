// packages/firebase_sdk/lib/src/repositories/user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_models/core_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('users');

  /// Creates or updates a user profile document in Firestore
  Future<void> createUserProfile(AppUser user) async {
    await _users.doc(user.uid).set(user.toJson());
  }

  /// Fetches a single user document by their UID
  Future<AppUser?> getUserById(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromJson(doc.data()!);
  }

  /// Updates specific fields in the user profile document
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update({
      ...data,
      'lastActive': DateTime.now().toIso8601String(),
    });
  }

  /// Updates FCM notification token for the user
  Future<void> updateFcmToken(String uid, String token) async {
    await _users.doc(uid).update({
      'fcmToken': token,
      'lastActive': DateTime.now().toIso8601String(),
    });
  }

  /// Streams user profile data in real time
  Stream<AppUser?> streamUserProfile(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromJson(doc.data()!);
    });
  }
}

// RIVERPOD PROVIDERS
final userRepositoryProvider = Provider((ref) => UserRepository());

final userProfileStreamProvider = StreamProvider.family<AppUser?, String>((ref, uid) {
  return ref.watch(userRepositoryProvider).streamUserProfile(uid);
});
