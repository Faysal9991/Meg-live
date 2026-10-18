import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/helper_functions/call_waiting_bottom_sheet_function.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/helper_functions/room_admin_button.dart';
import 'package:doyel_live/app/modules/products/controllers/vvip_or_vip_package_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'test_helpers.dart';

class _Packages extends VVIPorVipPackageController {
  @override
  Future<void> ensureKingPackageCatalogLoaded() async {}
}

void main() {
  late LiveStreamingController controller;
  late AuthController auth;
  final actions = <Map<String, dynamic>>[];
  final requestedPermissions = <int>[];
  var sendSucceeded = true;
  const permissionChannel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );
  setUp(() {
    Get.testMode = true;
    auth = Get.put<AuthController>(
      TestAuthController()..profile.value = buildTestProfile(),
    );
    controller = Get.put(LiveStreamingController())
      ..channelName.value = '100'
      ..setCurrentHost(100);
    Get.put<VVIPorVipPackageController>(_Packages());
    controller.listActiveCall.add({'uid': 100, 'full_name': 'Host'});
    actions.clear();
    requestedPermissions.clear();
    sendSucceeded = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (call) async {
          if (call.method == 'requestPermissions') {
            requestedPermissions.addAll((call.arguments as List).cast<int>());
            return {
              for (final permission in call.arguments as List) permission: 1,
            };
          }
          return 1;
        });
  });
  tearDown(() {
    Get.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
  });

  Future<void> openSheet(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showCallWaitingBottomSheet(
                context: context,
                data: {},
                streamingController: controller,
                authController: auth,
                onUpdateAction: (dynamic data) {
                  actions.add(Map<String, dynamic>.from(data));
                  return sendSucceeded;
                },
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  for (final audio in [true, false]) {
    testWidgets(
      '${audio ? 'audio' : 'video'} join requests preserve camera preference',
      (tester) async {
        await openSheet(tester);
        await tester.tap(find.text('Join'));
        await tester.pumpAndSettle();
        expect(actions, isEmpty);
        await tester.tap(find.text(audio ? 'Join audio' : 'Join video'));
        await tester.pumpAndSettle();
        expect(actions.single['action'], 'call_request');
        expect(actions.single['video_disabled'], audio);
        expect(actions.single['call_type'], 'video');
        expect(controller.videoDisabled.value, audio);
        // permission_handler uses 1 for camera and 7 for microphone.
        expect(requestedPermissions, audio ? [7] : [7, 1]);
      },
    );
  }

  testWidgets('dismissing join mode sends no request', (tester) async {
    await openSheet(tester);
    await tester.tap(find.text('Join'));
    await tester.pumpAndSettle();
    Navigator.pop(tester.element(find.text('Join audio')));
    await tester.pumpAndSettle();
    expect(actions, isEmpty);
    expect(requestedPermissions, isEmpty);
  });

  testWidgets('admin can reject requests and loses access when revoked', (
    tester,
  ) async {
    controller.listRequestedCall.add({
      'uid': 22,
      'full_name': 'Guest',
      'muted': false,
      'video_disabled': true,
    });
    await openSheet(tester);
    await tester.tap(find.text('WAITING'));
    await tester.pumpAndSettle();
    expect(find.byIcon(LucideIcons.check), findsNothing);
    controller.applyRoomAdmins(senderIdentity: '100', ids: [999]);
    await tester.pumpAndSettle();
    expect(find.byIcon(LucideIcons.check), findsOneWidget);
    expect(find.text('LIVE'), findsNothing); // No unrelated room powers.
    await tester.tap(find.byIcon(LucideIcons.x));
    await tester.pump();
    expect(actions.single['action'], 'cancel_request');
    controller.applyRoomAdmins(senderIdentity: '100', ids: []);
    await tester.pumpAndSettle();
    expect(find.byIcon(LucideIcons.check), findsNothing);
  });

  testWidgets('admin acceptance retains the requested camera-off state', (
    tester,
  ) async {
    sendSucceeded =
        false; // Capture the payload without issuing a backend write.
    controller.roomAdminIds.add(999);
    controller.listRequestedCall.add({
      'uid': 22,
      'full_name': 'Guest',
      'call_type': 'video',
      'muted': false,
      'video_disabled': true,
    });
    await openSheet(tester);
    await tester.tap(find.text('WAITING'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(LucideIcons.check));
    await tester.pump();
    expect(actions.single['action'], 'accept_general_callers');
    expect(actions.single['video_disabled'], isTrue);
    expect(actions.single['call_type'], 'video');
  });

  test('only the host identity can synchronize room admins', () {
    expect(
      controller.applyRoomAdmins(senderIdentity: '999', ids: [999]),
      isFalse,
    );
    expect(
      controller.applyRoomAdmins(senderIdentity: null, ids: [999]),
      isFalse,
    );
    expect(controller.isRoomAdmin, isFalse);
    expect(
      controller.applyRoomAdmins(senderIdentity: '100', ids: ['999']),
      isTrue,
    );
    expect(controller.isRoomAdmin, isTrue);
    controller.setClearStreamingRelatedFields();
    expect(controller.isRoomAdmin, isFalse);

    // After a handover only the new host may publish the admin list.
    controller.setCurrentHost(202);
    expect(
      controller.applyRoomAdmins(senderIdentity: '100', ids: [999]),
      isFalse,
    );
    expect(
      controller.applyRoomAdmins(senderIdentity: '202', ids: [999]),
      isTrue,
    );
  });

  testWidgets('host can assign and revoke a room admin', (tester) async {
    controller.isBroadcaster.value = true;
    controller.updateRoomAdmin = (uid, enabled) async {
      enabled
          ? controller.roomAdminIds.add(uid)
          : controller.roomAdminIds.remove(uid);
      return true;
    };
    await tester.pumpWidget(
      GetMaterialApp(home: const Scaffold(body: RoomAdminButton(uid: 22))),
    );
    await tester.tap(find.text('Make room admin'));
    await tester.pumpAndSettle();
    expect(controller.roomAdminIds.contains(22), isTrue);
    await tester.tap(find.text('Remove room admin'));
    await tester.pumpAndSettle();
    expect(controller.roomAdminIds.contains(22), isFalse);
  });
}
