import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoomAdminButton extends StatefulWidget {
  const RoomAdminButton({super.key, required this.uid, this.compact = false});
  final int uid;
  final bool compact;

  @override
  State<RoomAdminButton> createState() => _RoomAdminButtonState();
}

class _RoomAdminButtonState extends State<RoomAdminButton> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LiveStreamingController>();
    return Obx(() {
      final isAdmin = controller.roomAdminIds.contains(widget.uid);
      if (!controller.isBroadcaster.value ||
          widget.uid == controller.currentHostId.value) {
        return isAdmin ? const Text('Room admin') : const SizedBox.shrink();
      }
      final label = isAdmin ? 'Remove room admin' : 'Make room admin';
      Future<void> update() async {
        if (_saving || !controller.isBroadcaster.value) return;
        setState(() => _saving = true);
        bool saved = false;
        try {
          saved =
              await controller.updateRoomAdmin?.call(widget.uid, !isAdmin) ??
              false;
        } finally {
          if (mounted) setState(() => _saving = false);
        }
        if (!context.mounted || saved) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not update room admin. Please try again.'),
          ),
        );
      }

      if (widget.compact) {
        return IconButton(
          tooltip: label,
          onPressed: _saving ? null : update,
          icon: Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.person_add_alt_1,
          ),
        );
      }
      return TextButton.icon(
        onPressed: _saving ? null : update,
        icon: const Icon(Icons.admin_panel_settings),
        label: Text(label),
      );
    });
  }
}
