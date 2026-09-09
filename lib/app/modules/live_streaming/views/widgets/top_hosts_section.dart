import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/modules/live_streaming/models/top_host.dart';
import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/widgets/app_design_widgets.dart';
import 'package:flutter/material.dart';

class TopHostsSection extends StatelessWidget {
  const TopHostsSection({
    super.key,
    required this.hosts,
    required this.loading,
    required this.onHostTap,
  });
  final List<TopHost> hosts;
  final bool loading;
  final ValueChanged<TopHost> onHostTap;

  @override
  Widget build(BuildContext context) {
    if (hosts.isEmpty) {
      return loading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            'Top Hosts',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 112 + 34 * MediaQuery.textScalerOf(context).scale(1),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            itemCount: hosts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final host = hosts[index];
              return SizedBox(
                width: 112,
                child: AppCard(
                  child: InkWell(
                    onTap: () => onHostTap(host),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColors.primarySoft,
                            backgroundImage:
                                host.profileImage != null &&
                                    host.profileImage!.isNotEmpty
                                ? CachedNetworkImageProvider(host.profileImage!)
                                : null,
                            child:
                                host.profileImage == null ||
                                    host.profileImage!.isEmpty
                                ? const Icon(
                                    Icons.person_outline,
                                    color: AppColors.primary,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            host.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
