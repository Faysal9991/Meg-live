import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Lets the current host hand the live over to [uid]. The live room screen
/// owns the transfer flow through [LiveStreamingController.requestHostTransfer].
class TransferHostButton extends StatelessWidget {
  const TransferHostButton({super.key, required this.uid, this.fullName});
  final int uid;
  final String? fullName;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LiveStreamingController>();
    return Obx(() {
      final transferring = controller.transferringHost.value;
      if (!controller.isCurrentHost ||
          uid == controller.currentHostId.value ||
          controller.requestHostTransfer == null) {
        return const SizedBox.shrink();
      }
      return TextButton.icon(
        onPressed: transferring
            ? null
            : () {
                Navigator.of(context).pop();
                controller.requestHostTransfer?.call(uid, fullName);
              },
        icon: transferring
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(LucideIcons.crown),
        label: const Text('Make host'),
      );
    });
  }
}
