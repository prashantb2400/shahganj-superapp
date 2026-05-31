import 'package:freezed_annotation/freezed_annotation.dart';
import 'order_model.dart'; // Reuses Review schema

part 'booking_model.freezed.dart';
part 'booking_model.g.dart';

@freezed
class BookingModel with _$BookingModel {
  const factory BookingModel({
    required String id,
    required String customerId,
    required String providerId,
    required String serviceType,       // 'electrician' | 'plumber' | 'beauty' | 'hospital'
    required String issueDescription,
    @Default([]) List<String> problemPhotos,
    required BookingAddress address,
    required DateTime scheduledDate,
    required String scheduledTime,     // '09:00 AM' slot format
    @Default('pending') String status, // 'pending' | 'accepted' | 'in_progress' | 'completed' | 'cancelled'
    BookingPricing? pricing,
    String? otpHash,                   // SHA-256 of completed job verification OTP
    Review? review,
    DateTime? createdAt,
  }) = _BookingModel;

  factory BookingModel.fromJson(Map<String, dynamic> json) => _$BookingModelFromJson(json);
}

@freezed
class BookingAddress with _$BookingAddress {
  const factory BookingAddress({
    required String formattedAddress,
    required double latitude,
    required double longitude,
    String? houseNumber,
    String? landmark,
  }) = _BookingAddress;

  factory BookingAddress.fromJson(Map<String, dynamic> json) => _$BookingAddressFromJson(json);
}

@freezed
class BookingPricing with _$BookingPricing {
  const factory BookingPricing({
    required double baseRate,          // Call-out charge
    @Default(0.0) double materialCharge,
    @Default(0.0) double serviceCharge,
    required double total,
    @Default(false) bool isPaid,
  }) = _BookingPricing;

  factory BookingPricing.fromJson(Map<String, dynamic> json) => _$BookingPricingFromJson(json);
}
