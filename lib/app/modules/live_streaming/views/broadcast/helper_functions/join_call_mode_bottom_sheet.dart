import 'package:flutter/material.dart';

enum JoinCallMode { audio, video }

Future<JoinCallMode?> showJoinCallModeBottomSheet(BuildContext context) =>
    showModalBottomSheet<JoinCallMode>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Join call',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.mic),
              title: const Text('Join audio'),
              subtitle: const Text('Camera off. You can turn it on later.'),
              onTap: () => Navigator.pop(context, JoinCallMode.audio),
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Join video'),
              subtitle: const Text('Camera on'),
              onTap: () => Navigator.pop(context, JoinCallMode.video),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
