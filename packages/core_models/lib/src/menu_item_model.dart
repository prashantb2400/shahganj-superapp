import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_item_model.freezed.dart';
part 'menu_item_model.g.dart';

@freezed
class MenuItemModel with _$MenuItemModel {
  const factory MenuItemModel({
    required String id,
    required String merchantId,
    required String name,
    String? description,
    @Default('Main Course') String category,
    String? imageUrl,
    @Default(true) bool isVeg,
    @Default(true) bool isAvailable,
    @Default(false) bool hasHalfPortion,
    required double fullPrice,
    double? halfPrice,
    @Default([]) List<Addon> addons,
    @Default(20) int preparationTime,
    @Default(0) int popularityScore,
  }) = _MenuItemModel;

  factory MenuItemModel.fromJson(Map<String, dynamic> json) => _$MenuItemModelFromJson(json);
}

@freezed
class Addon with _$Addon {
  const factory Addon({
    required String name,
    required double price,
    @Default(false) bool isAvailable,
  }) = _Addon;

  factory Addon.fromJson(Map<String, dynamic> json) => _$AddonFromJson(json);
}
