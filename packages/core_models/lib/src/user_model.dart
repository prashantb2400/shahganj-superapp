import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,               // Firebase Auth UID (Google)
    required String displayName,       // Google profile name
    required String email,             // Google email
    String? phone,                     // +91XXXXXXXXXX (collected post-auth)
    String? avatar,                    // Google photo URL
    @Default('customer') String role,  // 'customer' | 'merchant' | 'rider' | 'admin'
    DateTime? createdAt,
    DateTime? lastActive,
    @Default([]) List<SavedAddress> savedAddresses,
    String? fcmToken,
    @Default(true) bool isActive,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}

@freezed
class SavedAddress with _$SavedAddress {
  const factory SavedAddress({
    required String id,
    required String label,             // 'Home', 'Work', etc.
    required String addressLine,
    required double latitude,
    required double longitude,
    @Default(false) bool isDefault,
  }) = _SavedAddress;

  factory SavedAddress.fromJson(Map<String, dynamic> json) => _$SavedAddressFromJson(json);
}
