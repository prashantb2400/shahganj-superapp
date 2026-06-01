import 'package:freezed_annotation/freezed_annotation.dart';

part 'ad_model.freezed.dart';
part 'ad_model.g.dart';

@freezed
class AdModel with _$AdModel {
  const factory AdModel({
    required String adId,
    required String imageUrl,
    required String title,
    required String deepLink,
    @Default(0) int priority,
    DateTime? startDate,
    DateTime? endDate,
  }) = _AdModel;

  factory AdModel.fromJson(Map<String, dynamic> json) => _$AdModelFromJson(json);
}
