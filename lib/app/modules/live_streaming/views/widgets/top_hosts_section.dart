import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

// class TopHostsSection extends StatelessWidget {
//   const TopHostsSection({
//     super.key,
//     required this.hosts,
//     required this.loading,
//     required this.onHostTap,
//   });

//   final List<TopHost> hosts;
//   final bool loading;
//   final ValueChanged<TopHost> onHostTap;

//   @override
//   Widget build(BuildContext context) {
//     if (loading && hosts.isEmpty) {
//       return const SizedBox(
//         height: 130,
//         child: Center(child: CircularProgressIndicator()),
//       );
//     }
//     if (hosts.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 8),
//           child: Text(
//             'Top Hosts',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//           ),
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           height: 188,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             itemBuilder: (context, index) {
//               final host = hosts[index];
//               return InkWell(
//                 borderRadius: BorderRadius.circular(20),
//                 onTap: () => onHostTap(host),
//                 child: Container(
//                   width: 180,
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF152238), Color(0xFF284B63)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 26,
//                             backgroundColor: Colors.white24,
//                             backgroundImage: host.profileImage != null
//                                 ? CachedNetworkImageProvider(host.profileImage!)
//                                 : null,
//                             child: host.profileImage == null
//                                 ? const Icon(Icons.person, color: Colors.white)
//                                 : null,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   host.fullName,
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                                 Text(
//                                   'ID #${host.uid}',
//                                   style: const TextStyle(
//                                     color: Colors.white70,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const Icon(
//                             Icons.workspace_premium,
//                             color: Colors.amber,
//                             size: 22,
//                           ),
//                         ],
//                       ),
//                       const Spacer(),
//                       Text(
//                         _formatSeconds(host.seconds),
//                         style: const TextStyle(
//                           color: Colors.amber,
//                           fontWeight: FontWeight.w700,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Wrap(
//                         spacing: 6,
//                         runSpacing: 6,
//                         children: [
//                           if (host.isAgent) _RolePill(label: 'Agent'),
//                           if (host.isReseller) _RolePill(label: 'Reseller'),
//                           if (host.isHost) _RolePill(label: 'Host'),
//                           if (host.isModerator) _RolePill(label: 'Mod'),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemCount: hosts.length,
//           ),
//         ),
//       ],
//     );
//   }

//   String _formatSeconds(int seconds) {
//     final duration = Duration(seconds: seconds);
//     String twoDigits(int value) => value.toString().padLeft(2, '0');
//     return [
//       twoDigits(duration.inHours),
//       twoDigits(duration.inMinutes.remainder(60)),
//       twoDigits(duration.inSeconds.remainder(60)),
//     ].join(':');
//   }
// }

class _RolePill extends StatelessWidget {
  const _RolePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white12,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.onPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
