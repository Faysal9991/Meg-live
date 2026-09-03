import 'package:doyel_live/app/modules/balance/models/withdraw_models.dart';
import 'package:doyel_live/app/modules/live_streaming/models/home_banner.dart';
import 'package:doyel_live/app/modules/live_streaming/models/top_host.dart';
import 'package:doyel_live/app/modules/products/models/king_package_catalog_state.dart';
import 'package:doyel_live/app/data/profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('profile parses active entry effect from top-level response', () {
    final profile = Profile.fromJson({
      'entry_effect': {
        'id': 1,
        'title': 'Super Car Entry',
        'gif': 'https://example.com/car.gif',
        'audio': 'https://example.com/car.mp3',
        'expired_datetime': '2028-08-27T10:18:36+00:00',
      },
    });

    expect(profile.entryEffect?.id, 1);
    expect(profile.entryEffect?.title, 'Super Car Entry');
    expect(profile.entryEffect?.gifUrl, 'https://example.com/car.gif');
    expect(profile.toJson()['entry_effect']['audio'], contains('car.mp3'));
  });

  test('profile falls back to entry effect inside encoded VIP preference', () {
    final profile = Profile.fromJson({
      'vvip_or_vip_preference':
          '{"rank":90000,"entry_effect":{"id":2,"title":"Bike Entry"}}',
    });

    expect(profile.entryEffect?.id, 2);
    expect(profile.entryEffect?.title, 'Bike Entry');
  });

  test('home models parse documented response shapes', () {
    final banner = HomeBanner.fromJson({'image': 'https://example.com/banner'});
    final host = TopHost.fromJson({
      'uid': 123,
      'level': {'level': 7},
      'vvip_or_vip_preference': {'vvip_or_vip_gif': 'gif'},
      'full_name': 'Host',
      'profile_image': 'https://example.com/host',
      'seconds': 12345,
      'is_agent': true,
      'is_reseller': false,
      'is_host': true,
      'is_moderator': false,
    });

    expect(banner.image, contains('banner'));
    expect(host.uid, 123);
    expect(host.isAgent, isTrue);
  });

  test('king package state parses full response', () {
    final state = KingPackageCatalogState.fromJson({
      'purchased_king_package': {
        'id': 4,
        'expired_datetime': '2026-03-10T10:00:00.000Z',
        'king_package': {
          'id': 7,
          'price': 1200,
          'days': 30,
          'gif': 'https://example.com/king.gif',
        },
      },
      'king_package_ordering_info': {'context': 'Contact us'},
      'king_package_list': [
        {
          'id': 7,
          'price': 1200,
          'days': 30,
          'gif': 'https://example.com/king.gif',
        },
      ],
    });

    expect(state.purchasedKingPackage, isNotNull);
    expect(state.kingPackageList.single.days, 30);
    expect(state.kingPackageOrderingInfo['context'], 'Contact us');
  });

  test('withdraw models parse list and options', () {
    final requestItem = WithdrawRequestItem.fromJson({
      'id': 1,
      'payment_method': {'id': 10},
      'payment_method_name': 'Bkash',
      'account_type': 'personal',
      'amount': 1000,
      'received_amount': 980,
      'receiver_number': '01700000000',
      'feedback': 'Pending',
      'is_pending': true,
      'is_accepted': false,
      'is_declined': false,
      'requested_datetime': '2026-03-05T10:00:00.000Z',
    });
    final packageOption = WithdrawPackageOption.fromJson({
      'id': 3,
      'diamonds': 100,
      'price': '5000.00',
    });
    final requiredMethod = PaymentMethodOption.fromJson({
      'id': 10,
      'title': 'Bkash',
      'account_types': ['personal', 'agent'],
    });
    final optionalMethod = PaymentMethodOption.fromJson({
      'id': 11,
      'title': 'Nagad',
      'account_types': null,
    });
    final payload = WithdrawRequestCreateRequest(
      withdrawPackageId: 3,
      paymentMethodId: 10,
      receiverNumber: '01700000000',
      accountType: 'personal',
    ).toJson();

    expect(requestItem.isPending, isTrue);
    expect(packageOption.label, contains('100 Diamonds'));
    expect(packageOption.label, contains('5000.00 BDT'));
    expect(requiredMethod.requiresAccountType, isTrue);
    expect(optionalMethod.requiresAccountType, isFalse);
    expect(payload['withdraw_package_id'], '3');
    expect(payload['payment_method_id'], '10');
  });
}
