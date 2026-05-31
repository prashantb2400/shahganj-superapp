import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required String customerId,
    required String merchantId,
    String? riderId,
    required List<OrderItem> items,
    required PricingBreakdown totals,
    required DeliveryAddress deliveryAddress,
    @Default('pending') String status, // 'pending' | 'confirmed' | 'preparing' | 'ready' | 'picked_up' | 'delivered' | 'cancelled'
    @Default([]) List<TimelineEvent> timeline,
    DateTime? estimatedDeliveryTime,
    DateTime? actualDeliveryTime,
    PaymentInfo? payment,
    String? otpHash,      // SHA-256 of 4-digit OTP (stored in Firestore)
    String? otp,          // Plain text OTP displayed only on customer screen
    Review? review,
    String? notes,
    DateTime? createdAt,
    @Default('food') String orderType,  // 'food' | 'mart'
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);
}

@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String itemId,
    required String name,
    required int quantity,
    required double price,
    @Default(false) bool isHalf,
    @Default([]) List<String> selectedAddons,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
}

@freezed
class PricingBreakdown with _$PricingBreakdown {
  const factory PricingBreakdown({
    required double subtotal,
    @Default(0.0) double deliveryFee,
    @Default(0.0) double tax,
    @Default(0.0) double discount,
    required double total,             // legacy 'total_amount' normalized as 'total'
  }) = _PricingBreakdown;

  factory PricingBreakdown.fromJson(Map<String, dynamic> json) => _$PricingBreakdownFromJson(json);
}

@freezed
class DeliveryAddress with _$DeliveryAddress {
  const factory DeliveryAddress({
    required String formattedAddress,
    required double latitude,
    required double longitude,
    String? landmark,
    String? receiverName,
    String? receiverPhone,
  }) = _DeliveryAddress;

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) => _$DeliveryAddressFromJson(json);
}

@freezed
class TimelineEvent with _$TimelineEvent {
  const factory TimelineEvent({
    required String status,
    required String title,
    required String description,
    required DateTime timestamp,
  }) = _TimelineEvent;

  factory TimelineEvent.fromJson(Map<String, dynamic> json) => _$TimelineEventFromJson(json);
}

@freezed
class PaymentInfo with _$PaymentInfo {
  const factory PaymentInfo({
    required String transactionId,
    required String method,            // 'upi' | 'card' | 'cod'
    required String status,            // 'pending' | 'success' | 'failed'
    required DateTime timestamp,
  }) = _PaymentInfo;

  factory PaymentInfo.fromJson(Map<String, dynamic> json) => _$PaymentInfoFromJson(json);
}

@freezed
class Review with _$Review {
  const factory Review({
    required double rating,
    String? comment,
    DateTime? createdAt,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
}
