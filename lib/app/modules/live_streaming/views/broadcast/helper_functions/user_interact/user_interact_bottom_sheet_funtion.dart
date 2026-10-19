import 'package:doyel_live/app/data/vip_preference.dart';
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
        child: SizedBox(
          height: _headerHeight + 1 + _contentHeight,
          child: Column(
            children: [
              _SheetHeader(user: user),
              const Divider(height: 1, color: AppColors.divider),
              Expanded(
                child: GiftsWidget(
                  data: user,
                  streamingController: streamingController,
                  authController: authController,
                  onUpdateAction: onUpdateAction,
                ),
              ),
            ],
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
  const _SheetHeader({required this.user});

  final Map<String, dynamic> user;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _headerHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            VipProfileAvatar(
              profileImage: user['profile_image'],
              vipPreference: user['vvip_or_vip_preference'],
              frameSize: 48,
              unframedSize: 36,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['full_name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (user['uid'] != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${user['uid']}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
