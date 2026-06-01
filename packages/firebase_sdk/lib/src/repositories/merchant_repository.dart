// packages/firebase_sdk/lib/src/repositories/merchant_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_models/core_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MerchantRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _merchants => _firestore.collection('merchants');
  CollectionReference<Map<String, dynamic>> get _menuItems => _firestore.collection('menuItems');
  CollectionReference<Map<String, dynamic>> get _ads => _firestore.collection('ads');

  /// Fetches a single merchant by ID
  Future<MerchantModel?> getMerchantById(String merchantId) async {
    final doc = await _merchants.doc(merchantId).get();
    if (!doc.exists) return null;
    return MerchantModel.fromJson(doc.data()!);
  }

  /// Streams a single merchant's details in real time
  Stream<MerchantModel?> streamMerchant(String merchantId) {
    return _merchants.doc(merchantId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return MerchantModel.fromJson(doc.data()!);
    });
  }

  /// Streams all approved merchants within a category, sorted by rating descending
  /// Enforces index: category ASC + status ASC + rating DESC
  Stream<List<MerchantModel>> streamMerchantsByCategory(String category) {
    return _merchants
        .where('category', isEqualTo: category)
        .where('status', isEqualTo: 'approved')
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MerchantModel.fromJson(doc.data()))
            .toList());
  }

  /// Streams available menu items for a merchant, ordered by popularity
  /// Enforces index: merchantId ASC + isAvailable ASC + popularityScore DESC
  Stream<List<MenuItemModel>> streamMenuItemsForMerchant(String merchantId) {
    return _menuItems
        .where('merchantId', isEqualTo: merchantId)
        .where('isAvailable', isEqualTo: true)
        .orderBy('popularityScore', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuItemModel.fromJson(doc.data()))
            .toList());
  }

  /// Streams all active promotional ads and banners sorted by priority
  Stream<List<AdModel>> streamActiveAds() {
    return _ads
        .orderBy('priority', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AdModel.fromJson(doc.data()))
            .toList());
  }
}

// RIVERPOD PROVIDERS
final merchantRepositoryProvider = Provider((ref) => MerchantRepository());

final merchantStreamProvider = StreamProvider.family<MerchantModel?, String>((ref, merchantId) {
  return ref.watch(merchantRepositoryProvider).streamMerchant(merchantId);
});

final merchantsByCategoryStreamProvider = StreamProvider.family<List<MerchantModel>, String>((ref, category) {
  return ref.watch(merchantRepositoryProvider).streamMerchantsByCategory(category);
});

final menuItemsStreamProvider = StreamProvider.family<List<MenuItemModel>, String>((ref, merchantId) {
  return ref.watch(merchantRepositoryProvider).streamMenuItemsForMerchant(merchantId);
});

final activeAdsStreamProvider = StreamProvider((ref) {
  return ref.watch(merchantRepositoryProvider).streamActiveAds();
});
