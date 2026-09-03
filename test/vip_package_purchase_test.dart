import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/products/controllers/vvip_or_vip_package_controller.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'test_helpers.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
    final authController = TestAuthController();
    authController.profile.value = buildTestProfile();
    Get.put<AuthController>(authController);
  });

  tearDown(Get.reset);

  test(
    'VIP purchase sends the selected package ID and refreshes the list',
    () async {
      final adapter = _PackagePurchaseAdapter();
      final controller = VVIPorVipPackageController(
        dio: Dio()..httpClientAdapter = adapter,
      );

      final statusCode = await controller.purchaseVIPPackage(packageId: 2);

      expect(statusCode, 201);
      expect(adapter.postRequests, hasLength(1));
      expect(adapter.postRequests.single.path, kVipPackagePurchaseUrl);
      expect(adapter.postRequests.single.data, {'vip_package_id': 2});
      expect(controller.purchasedVipPackage['id'], 20);
      expect(controller.purchasingVIPPackage.value, isFalse);
    },
  );

  test(
    'VVIP purchase sends the selected package ID and refreshes the list',
    () async {
      final adapter = _PackagePurchaseAdapter();
      final controller = VVIPorVipPackageController(
        dio: Dio()..httpClientAdapter = adapter,
      );

      final statusCode = await controller.purchaseVVIPPackage(packageId: 1);

      expect(statusCode, 201);
      expect(adapter.postRequests, hasLength(1));
      expect(adapter.postRequests.single.path, kVvipPackagePurchaseUrl);
      expect(adapter.postRequests.single.data, {'vvip_package_id': 1});
      expect(controller.purchasedVVipPackage['id'], 10);
      expect(controller.purchasingVVIPPackage.value, isFalse);
    },
  );

  test(
    'entry effect purchase sends the selected package ID and refreshes status',
    () async {
      final adapter = _PackagePurchaseAdapter();
      final controller = VVIPorVipPackageController(
        dio: Dio()..httpClientAdapter = adapter,
      );

      final statusCode = await controller.purchaseEntryEffectPackage(
        packageId: 1,
      );

      expect(statusCode, 201);
      expect(adapter.postRequests, hasLength(1));
      expect(adapter.postRequests.single.path, kPurchasedEntryEffectPackageUrl);
      expect(adapter.postRequests.single.data, {'entry_effect_package_id': 1});
      expect(controller.purchasedEntryEffectPackage['id'], 30);
      expect(controller.entryEffectPackageList.single['title'], 'Super Car');
      expect(controller.purchasingEntryEffectPackage.value, isFalse);
    },
  );
}

class _PackagePurchaseAdapter implements HttpClientAdapter {
  final List<RequestOptions> postRequests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.method == 'POST') {
      postRequests.add(options);
      return _jsonResponse(201, {'success': true});
    }

    if (options.path == kPurchasedVIPPackageListUrl) {
      return _jsonResponse(200, {
        'vip_package_list': <dynamic>[],
        'purchased_vip_package': {'id': 20},
        'vip_package_ordering_info': <String, dynamic>{},
      });
    }

    if (options.path == kPurchasedVvIPPackageListUrl) {
      return _jsonResponse(200, {
        'vvip_package_list': <dynamic>[],
        'purchased_vvip_package': {'id': 10},
        'vvip_package_ordering_info': <String, dynamic>{},
      });
    }

    if (options.path == kPurchasedEntryEffectPackageListUrl) {
      return _jsonResponse(200, {
        'purchased_entry_effect_package': {
          'id': 30,
          'entry_effect_package': {
            'id': 1,
            'title': 'Super Car',
            'price': 5000,
            'days': 30,
          },
        },
        'entry_effect_package_list': [
          {
            'id': 1,
            'title': 'Super Car',
            'price': 5000,
            'days': 30,
            'is_active': true,
          },
        ],
      });
    }

    return _jsonResponse(404, {'detail': 'Not found'});
  }

  ResponseBody _jsonResponse(int statusCode, Map<String, dynamic> data) {
    return ResponseBody.fromString(
      jsonEncode(data),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
