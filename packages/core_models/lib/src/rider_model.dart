import 'package:freezed_annotation/freezed_annotation.dart';

part 'rider_model.freezed.dart';
part 'rider_model.g.dart';

@freezed
class RiderModel with _$RiderModel {
  const factory RiderModel({
    required String uid,
    required String merchantId,
    required String name,
    required String phone,
    required String vehicleNumber,
    @Default('bike') String vehicleType, // 'bike' | 'scooter' | 'e-rickshaw'
    @Default(false) bool isOnline,
    double? latitude,
    double? longitude,
    DateTime? locationTimestamp,
    @Default('offline') String status,   // 'available' | 'busy' | 'offline'
    @Default(0) int totalDeliveries,
    @Default(0.0) double earnings,
    @Default(0.0) double rating,
    String? inviteCode,                  // 6-digit merchant-generated invite signup code
  }) = _RiderModel;

  factory RiderModel.fromJson(Map<String, dynamic> json) => _$RiderModelFromJson(json);
}
