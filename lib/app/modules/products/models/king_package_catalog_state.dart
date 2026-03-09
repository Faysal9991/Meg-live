import 'package:doyel_live/app/utils/model_parsers.dart';

class KingPackageItem {
  const KingPackageItem({
    required this.id,
    required this.price,
    required this.days,
    required this.gif,
    required this.raw,
  });

  final int id;
  final double price;
  final int days;
  final String gif;
  final Map<String, dynamic> raw;

  String get displayPrice {
    if (price == price.roundToDouble()) {
      return price.toInt().toString();
    }
    return price.toStringAsFixed(2);
  }

  factory KingPackageItem.fromJson(Map<String, dynamic> json) {
    return KingPackageItem(
      id: intFromDynamic(json['id']),
      price: doubleFromDynamic(json['price']),
      days: intFromDynamic(json['days']),
      gif: firstStringFromKeys(json, const ['gif', 'image']),
      raw: Map<String, dynamic>.from(json),
    );
  }
}

class PurchasedKingPackage {
  const PurchasedKingPackage({
    required this.id,
    required this.kingPackage,
    required this.expiredDatetime,
  });

  final int id;
  final KingPackageItem? kingPackage;
  final String? expiredDatetime;

  factory PurchasedKingPackage.fromJson(Map<String, dynamic> json) {
    final kingPackageData = mapFromDynamic(json['king_package']);
    return PurchasedKingPackage(
      id: intFromDynamic(json['id']),
      kingPackage: kingPackageData.isEmpty
          ? null
          : KingPackageItem.fromJson(kingPackageData),
      expiredDatetime: nullableStringFromDynamic(json['expired_datetime']),
    );
  }
}

class KingPackageCatalogState {
  const KingPackageCatalogState({
    required this.purchasedKingPackage,
    required this.kingPackageOrderingInfo,
    required this.kingPackageList,
  });

  final PurchasedKingPackage? purchasedKingPackage;
  final Map<String, dynamic> kingPackageOrderingInfo;
  final List<KingPackageItem> kingPackageList;

  factory KingPackageCatalogState.empty() {
    return const KingPackageCatalogState(
      purchasedKingPackage: null,
      kingPackageOrderingInfo: <String, dynamic>{},
      kingPackageList: <KingPackageItem>[],
    );
  }

  factory KingPackageCatalogState.fromJson(Map<String, dynamic> json) {
    final purchasedData = mapFromDynamic(json['purchased_king_package']);
    final packageList = mapListFromDynamic(json, key: 'king_package_list');
    return KingPackageCatalogState(
      purchasedKingPackage: purchasedData.isEmpty
          ? null
          : PurchasedKingPackage.fromJson(purchasedData),
      kingPackageOrderingInfo: mapFromDynamic(
        json['king_package_ordering_info'],
      ),
      kingPackageList: packageList
          .map(KingPackageItem.fromJson)
          .toList(growable: false),
    );
  }
}
