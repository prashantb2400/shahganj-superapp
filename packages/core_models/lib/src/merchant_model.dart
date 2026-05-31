import 'package:freezed_annotation/freezed_annotation.dart';

part 'merchant_model.freezed.dart';
part 'merchant_model.g.dart';

@freezed
class MerchantModel with _$MerchantModel {
  const factory MerchantModel({
    required String uid,
    required String businessName,
    required String ownerName,
    required String phone,
    required String email,
    required String category,          // 'restaurant' | 'electrician' | 'plumber' | 'beauty' | 'hospital' | 'car_rental' | 'mart'
    @Default('pending') String status, // 'pending' | 'approved' | 'rejected' | 'suspended'
    double? latitude,
    double? longitude,
    String? addressFormatted,
    @Default({}) Map<String, String> documents,
    MerchantSettings? settings,
    @Default(0.0) double rating,
    @Default(0) int ratingCount,
    @Default(false) bool isOpen,
    DateTime? createdAt,
    DateTime? approvedAt,
    String? approvedBy,
    String? rejectionReason,
  }) = _MerchantModel;

  factory MerchantModel.fromJson(Map<String, dynamic> json) => _$MerchantModelFromJson(json);
}

@freezed
class MerchantSettings with _$MerchantSettings {
  const factory MerchantSettings({
    @Default(100.0) double minOrder,
    @Default(5.0) double deliveryRadius,
    @Default(20.0) double deliveryFee,
    @Default(25) int avgPrepTime,
    @Default(200.0) double hourlyRate,  // for service providers
    @Default([]) List<String> deliverySlots,
    @Default([]) List<String> availableDays,
    String? serviceAreaRadius,
  }) = _MerchantSettings;

  factory MerchantSettings.fromJson(Map<String, dynamic> json) => _$MerchantSettingsFromJson(json);
}
