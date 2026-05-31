import 'package:freezed_annotation/freezed_annotation.dart';
import 'order_model.dart'; // Reuses PaymentInfo & Review

part 'ride_model.freezed.dart';
part 'ride_model.g.dart';

@freezed
class RideModel with _$RideModel {
  const factory RideModel({
    required String id,
    required String customerId,
    String? driverId,
    @Default('e_rickshaw') String type,         // 'e_rickshaw' | 'car_rental'
    @Default('whole') String bookingType,       // 'whole' | 'share'
    @Default(1) int seatCount,
    required RideLocation pickup,
    required RideLocation drop,
    RouteInfo? route,
    FareBreakdown? fare,
    @Default('searching') String status,        // 'searching' | 'accepted' | 'arrived' | 'ongoing' | 'completed' | 'cancelled'
    String? otpHash,
    PaymentInfo? payment,
    Review? review,
    DateTime? createdAt,
  }) = _RideModel;

  factory RideModel.fromJson(Map<String, dynamic> json) => _$RideModelFromJson(json);
}

@freezed
class RideLocation with _$RideLocation {
  const factory RideLocation({
    required String name,
    required double latitude,
    required double longitude,
  }) = _RideLocation;

  factory RideLocation.fromJson(Map<String, dynamic> json) => _$RideLocationFromJson(json);
}

@freezed
class RouteInfo with _$RouteInfo {
  const factory RouteInfo({
    required String polyline,           // OSRM compressed geometry string
    required double distanceKm,
    required double durationMinutes,
  }) = _RouteInfo;

  factory RouteInfo.fromJson(Map<String, dynamic> json) => _$RouteInfoFromJson(json);
}

@freezed
class FareBreakdown with _$FareBreakdown {
  const factory FareBreakdown({
    required double base,              // ₹20 whole | ₹10 per seat share
    required double perKm,             // ₹15 whole | ₹5 per seat share
    required double distance,
    required double total,
  }) = _FareBreakdown;

  factory FareBreakdown.fromJson(Map<String, dynamic> json) => _$FareBreakdownFromJson(json);
}
