import 'package:doyel_live/app/data/vip_preference.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/helper_functions/user_interact/widgets/contributors_widget.dart';
import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/theme/app_radius.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/helper_functions/user_interact/widgets/gifts_widget.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/widgets/vip_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const double _headerHeight = 64;
const double _contentHeight = 300;

void showUserInteractBottomSheet({
  required BuildContext context,
  required dynamic data,
  required Function onUpdateAction,
}) {
  final AuthController authController = Get.find();
  final LiveStreamingController streamingController = Get.find();
  final user = _normalizeUser(data);

  showModalBottomSheet(
    context: context,
    barrierColor: AppColors.transparent,
    backgroundColor: AppColors.surface,
    enableDrag: false,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    builder: (context) {
      return SafeArea(
        child: Obx(
          () => SizedBox(
            height: _headerHeight + 1 + _contentHeight,
            child: Column(
              children: [
                _SheetHeader(
                  user: user,
                  streamingController: streamingController,
                ),
                const Divider(height: 1, color: AppColors.divider),
                Expanded(
                  child: streamingController.userInteractTab.value == 'gifts'
                      ? GiftsWidget(
                          data: user,
                          streamingController: streamingController,
                          authController: authController,
                          onUpdateAction: onUpdateAction,
                        )
                      : ContributorsWidget(
                          streamingController: streamingController,
                          data: user,
                          onUpdateAction: onUpdateAction,
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Callers pass user maps from several sources (host fields, LiveKit
/// participants, socket payloads), so field types and fallbacks differ.
/// Normalize once here so every child widget reads the same shape.
Map<String, dynamic> _normalizeUser(dynamic data) {
  final source = data is Map
      ? Map<String, dynamic>.from(data)
      : <String, dynamic>{};
  String? nonEmpty(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty || text == 'null' ? null : text;
  }

  final uid = int.tryParse('${source['uid'] ?? source['user']?['uid']}');
  return {
    ...source,
    'uid': uid,
    'full_name':
        nonEmpty(source['full_name']) ?? 'User${uid != null ? ' #$uid' : ''}',
    'profile_image':
        nonEmpty(source['profile_image']) ?? nonEmpty(source['photo_url']),
    'vvip_or_vip_preference': normalizeVipPreference(
      source['vvip_or_vip_preference'],
    ),
  };
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.user, required this.streamingController});

  final Map<String, dynamic> user;
  final LiveStreamingController streamingController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _headerHeight,
      child: Row(
        children: [
          Expanded(
            child: _tab(
              tab: 'gifts',
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.card_giftcard_rounded, size: 20),
                  SizedBox(height: 4),
                  Text('SEND GIFTS', maxLines: 1),
                ],
              ),
            ),
          ),
          Expanded(
            child: _tab(
              tab: 'contributors',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VipProfileAvatar(
                    profileImage: user['profile_image'],
                    vipPreference: user['vvip_or_vip_preference'],
                    frameSize: 30,
                    unframedSize: 24,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user['full_name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab({required String tab, required Widget child}) {
    return Obx(() {
      final selected = streamingController.userInteractTab.value == tab;
      return Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: () => streamingController.setUserInteractTab(tab: tab),
          child: SizedBox.expand(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.surfaceInset
                    : AppColors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border(
                  bottom: BorderSide(
                    color: selected ? AppColors.primary : AppColors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: DefaultTextStyle.merge(
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                child: IconTheme.merge(
                  data: IconThemeData(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
