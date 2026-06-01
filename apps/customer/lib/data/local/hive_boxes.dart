// apps/customer/lib/data/local/hive_boxes.dart
import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxes {
  static const String guestCartBoxName = 'guest_cart';
  static const String userPrefsBoxName = 'user_preferences';

  static Box get _guestCartBox => Hive.box(guestCartBoxName);
  static Box get _userPrefsBox => Hive.box(userPrefsBoxName);

  /// Saves the active offline cart for a specific merchant
  static Future<void> saveCart(String merchantId, List<Map<String, dynamic>> serializedItems) async {
    await _guestCartBox.put('merchantId', merchantId);
    await _guestCartBox.put('items', serializedItems);
  }

  /// Retrieves the guest cart details as a Map
  static Map<String, dynamic> getCart() {
    final merchantId = _guestCartBox.get('merchantId') as String?;
    final itemsList = _guestCartBox.get('items') as List?;
    
    return {
      'merchantId': merchantId ?? '',
      'items': itemsList?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [],
    };
  }

  /// Clears the guest cart (e.g. after successful order or cart reset)
  static Future<void> clearCart() async {
    await _guestCartBox.delete('merchantId');
    await _guestCartBox.delete('items');
  }

  /// Save simple user preference key-value pair
  static Future<void> savePreference(String key, dynamic value) async {
    await _userPrefsBox.put(key, value);
  }

  /// Retrieve user preference with a fallback default value
  static dynamic getPreference(String key, {dynamic defaultValue}) {
    return _userPrefsBox.get(key, defaultValue: defaultValue);
  }
}
