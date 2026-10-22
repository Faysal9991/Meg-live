import 'package:doyel_live/app/data/profile_model.dart';
import 'package:flutter/services.dart';
import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/widgets/vip_profile_avatar.dart';
import 'package:doyel_live/app/widgets/diamond_icon.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/auth/views/change_password_view.dart';
import 'package:doyel_live/app/modules/business/views/agent/agent_for_host_view.dart';
import 'package:doyel_live/app/modules/business/views/agent/hosts/hosts_view.dart';
import 'package:doyel_live/app/modules/business/views/host_requst_view.dart';
import 'package:doyel_live/app/modules/business/views/moderator/moderator_view.dart';
import 'package:doyel_live/app/modules/business/views/reseller/reseller_view.dart';
import 'package:doyel_live/app/modules/balance/views/withdraw_requests_view.dart';
import 'package:doyel_live/app/modules/products/views/entry_effect_package_view.dart';
import 'package:doyel_live/app/modules/products/views/vip_package_view.dart';
import 'package:doyel_live/app/modules/products/views/vvip_package_view.dart';
import 'package:doyel_live/app/modules/profile/views/block_list_view.dart';
import 'package:doyel_live/app/modules/profile/views/broadcasting_histories.dart';
import 'package:doyel_live/app/modules/profile/views/edit_profile_view.dart';
import 'package:doyel_live/app/modules/profile/views/feedback_view.dart';
import 'package:doyel_live/app/modules/profile/views/info/privacy_policy_view.dart';
import 'package:doyel_live/app/modules/profile/views/info/terms_and_conditions_view.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({super.key});

  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.bg,
    child: Obx(() {
      final profile = _authController.profile.value;
      final isAgent = profile.is_agent ?? false;
      final isModerator = profile.is_moderator ?? false;
      final isReseller = profile.is_reseller ?? false;
      final isHost = profile.is_host ?? false;
      final signingOut = _authController.authLoading.value;

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          children: [
            _identityCard(context, profile),
            // Move the stats and menu together to create the reference overlap
            // while allowing the identity and stats to grow with text scaling.
            Transform.translate(
              offset: const Offset(0, -30),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: _ProfileStats(profile: profile),
                  ),
                  const SizedBox(height: 18),
                  _ProfileActionTile(
                    icon: LucideIcons.userRoundCog,
                    label: 'Account',
                    iconColor: AppColors.primaryLight,
                    onTap: () => Get.to(() => const EditProfileView()),
                  ),
                  _ProfileActionTile(
                    icon: LucideIcons.wallet,
                    label: 'Wallet',
                    iconColor: AppColors.cyan,
                    onTap: () => _showWallet(context),
                  ),
                  _ProfileActionTile(
                    icon: LucideIcons.userRoundX,
                    label: 'Block List: ${profile.blocks?.length ?? 0}',
                    iconColor: AppColors.magenta,
                    onTap: () => Get.to(() => const BlockListView()),
                  ),
                  _ProfileActionTile(
                    icon: LucideIcons.history,
                    label: 'History',
                    iconColor: AppColors.info,
                    onTap: profile.user?.uid == null
                        ? null
                        : () => Get.to(
                            () => BroadcastingHistoriesView(
                              userId: profile.user!.uid!,
                              isAgentSearch: false,
                            ),
                          ),
                  ),
                  _ProfileActionTile(
                    icon: LucideIcons.coins,
                    label: 'Withdraw',
                    iconColor: AppColors.gold,
                    onTap: () => Get.to(() => const WithdrawRequestsView()),
                  ),
                  _ProfileActionTile(
                    icon: LucideIcons.crown,
                    label: 'VVIP Package',
                    iconColor: AppColors.gold,
                    onTap: () => Get.to(() => const VVIPPackageView()),
                  ),
                  _ProfileActionTile(
                    icon: LucideIcons.gem,
                    label: 'VIP Package',
                    iconColor: AppColors.gold,
                    onTap: () => Get.to(() => const VIPPackageView()),
                  ),
                  _ProfileActionTile(
                    icon: LucideIcons.wandSparkles,
                    label: 'Entry Effect',
                    iconColor: AppColors.primaryLight,
                    onTap: () => Get.to(() => const EntryEffectPackageView()),
                  ),
                  if (profile.login_type == 'password_login')
                    _ProfileActionTile(
                      icon: LucideIcons.lockKeyhole,
                      label: 'Change Password',
                      onTap: () => Get.to(() => ChangePasswordView()),
                    ),
                  if (isModerator)
                    _ProfileActionTile(
                      icon: LucideIcons.badgeCheck,
                      label: 'Moderator Activity',
                      onTap: () => Get.to(() => ModeratorView()),
                    ),
                  if (isReseller)
                    _ProfileActionTile(
                      icon: LucideIcons.diamond,
                      label: 'Reseller Recharge',
                      onTap: () => Get.to(() => ResellerView()),
                    ),
                  if (isAgent)
                    _ProfileActionTile(
                      icon: LucideIcons.usersRound,
                      label: 'Host List',
                      onTap: () => Get.to(
                        () => HostsView(agentUserId: profile.user?.uid),
                      ),
                    ),
                  if (!isAgent && !isModerator && !isReseller && !isHost)
                    _ProfileActionTile(
                      icon: LucideIcons.radioTower,
                      label: 'Host Request',
                      onTap: () => Get.to(() => const HostRequstView()),
                    ),
                  if (isHost)
                    _ProfileActionTile(
                      icon: LucideIcons.headset,
                      label: 'My Agent',
                      onTap: () => Get.to(() => AgentForHostView()),
                    ),
                  _ProfileActionTile(
                    icon: LucideIcons.messageCircleQuestion,
                    label: 'Help & Feedback',
                    onTap: () => Get.to(() => const FeedbackView()),
                  ),
                  _ProfileActionTile(
                    icon: LucideIcons.shieldCheck,
                    label: 'Privacy Policy',
                    onTap: () => Get.to(() => const PrivacyPolicyView()),
                  ),
                  _ProfileActionTile(
                    icon: LucideIcons.scrollText,
                    label: 'Terms & Conditions',
                    onTap: () => Get.to(() => const TermsAndConditionsView()),
                  ),
                  _ProfileActionTile(
                    icon: LucideIcons.logOut,
                    label: signingOut ? 'Logging out…' : 'Log Out',
                    iconColor: AppColors.error,
                    textColor: AppColors.error,
                    isLoading: signingOut,
                    onTap: signingOut ? null : () => _confirmSignOut(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }),
  );

  Widget _identityCard(BuildContext context, Profile profile) {
    final email = profile.email?.trim() ?? '';
    final contact = email.isNotEmpty ? email : profile.user?.phone ?? '';
    final name = profile.full_name?.trim();
    final uid = profile.user?.uid;

    return Container(
      key: const ValueKey('profile-identity-card'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 58),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.deepViolet],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VipProfileAvatar(
            profileImage: profile.profile_image ?? profile.photo_url,
            vipPreference: profile.vvip_or_vip_preference,
            unframedSize: 86,
            frameSize: 98,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name == null || name.isEmpty ? 'User' : name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onMedia,
                  ),
                ),
                if (contact.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    contact,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onMedia,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'ID: ${uid ?? '—'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.onMediaMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: 'Copy user ID',
                      onPressed: uid == null
                          ? null
                          : () => _copyId(context, uid),
                      icon: const Icon(LucideIcons.copy, size: 17),
                      color: AppColors.onMedia,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyId(BuildContext context, int uid) async {
    await Clipboard.setData(ClipboardData(text: '$uid'));
    if (!context.mounted) return;
    final messenger = Scaffold.maybeOf(context) == null
        ? null
        : ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(const SnackBar(content: Text('User ID copied')));
  }

  void _showWallet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: AppColors.surfaceElevated,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Obx(() {
            final profile = _authController.profile.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Wallet',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                _WalletAmount(
                  label: 'Diamonds',
                  value: profile.gift_diamonds ?? 0,
                  icon: const DiamondIcon(size: 28),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Get.to(() => const WithdrawRequestsView());
                  },
                  icon: const Icon(LucideIcons.coins),
                  label: const Text('Withdraw'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'Are you sure you want to log out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onLight,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (shouldSignOut == true) _authController.tryToSignOut();
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats({required this.profile});
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final level = profile.level;
    final levelNumber = level is Map ? int.tryParse('${level['level']}') : null;
    return Container(
      key: const ValueKey('profile-stats-card'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.bg.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ProfileMetric(
                  label: 'Diamonds',
                  value: '${profile.gift_diamonds ?? 0}',
                  icon: const DiamondIcon(),
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ProfileMetric(
                  label: 'Level',
                  value: 'L.V. ${levelNumber ?? '—'}',
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.borderLight),
          ),
          Row(
            children: [
              Expanded(
                child: _SocialStat(
                  label: 'Friends',
                  value: profile.friends_count,
                  icon: LucideIcons.usersRound,
                  color: AppColors.primaryLight,
                ),
              ),
              Container(width: 1, height: 38, color: AppColors.borderLight),
              Expanded(
                child: _SocialStat(
                  label: 'Followers',
                  value: profile.followers?.length ?? 0,
                  icon: LucideIcons.heart,
                  color: AppColors.magenta,
                ),
              ),
              Container(width: 1, height: 38, color: AppColors.borderLight),
              Expanded(
                child: _SocialStat(
                  label: 'Following',
                  value: profile.following_count,
                  icon: LucideIcons.userRoundPlus,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({
    required this.label,
    required this.value,
    required this.color,
    this.icon,
  });
  final String label, value;
  final Color color;
  final Widget? icon;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: '$label: $value',
    child: Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 4)],
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _SocialStat extends StatelessWidget {
  const _SocialStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final int? value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 5),
        Text(
          value?.toString() ?? '—',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = AppColors.primaryLight,
    this.textColor = AppColors.textPrimary,
    this.isLoading = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color iconColor, textColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        minTileHeight: 62,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        horizontalTitleGap: 14,
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: iconColor.withValues(alpha: 0.35)),
          ),
          child: isLoading
              ? SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: iconColor,
                  ),
                )
              : Icon(icon, size: 22, color: iconColor),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        trailing: isLoading
            ? null
            : const Icon(
                LucideIcons.chevronRight,
                size: 20,
                color: AppColors.textSecondary,
              ),
      ),
    ),
  );
}

class _WalletAmount extends StatelessWidget {
  const _WalletAmount({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final int value;
  final Widget icon;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      icon,
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          '$value',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    ],
  );
}
