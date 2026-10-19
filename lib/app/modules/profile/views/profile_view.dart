import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/theme/app_spacing.dart';
import 'package:doyel_live/app/theme/app_text_styles.dart';
import 'package:doyel_live/app/widgets/app_design_widgets.dart';
import 'package:doyel_live/app/widgets/vip_profile_avatar.dart';
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

class ProfileView extends GetView<ProfileController>{
  ProfileView({super.key});
  final AuthController _authController = Get.find();
  @override
  Widget build(BuildContext context) {
    final profile = _authController.profile.value;
    final isAgent = profile.is_agent ?? false;
    final isModerator = profile.is_moderator ?? false;
    final isReseller = profile.is_reseller ?? false;
    final isHost = profile.is_host ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Profile', style: AppTextStyles.pageTitle),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Obx(() {
                  final profile = _authController.profile.value;
                  return VipProfileAvatar(
                    profileImage: profile.profile_image ?? profile.photo_url,
                    vipPreference: profile.vvip_or_vip_preference,
                  );
                }),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Obx(() {
                          return Text(
                            '${_authController.profile.value.full_name}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          );
                        }),
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Obx(() {
                          return Text(
                            _authController.profile.value.user?.phone ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          );
                        }),
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   children: [
                      //     Text(
                      //       'ID:  ${_authController.profile.value.user!.uid!}',
                      //       style: const TextStyle(
                      //         color: AppColors.textPrimary,
                      //       ),
                      //     ),
                      //     const SizedBox(
                      //       width: 16,
                      //     ),
                      //     Obx(() {
                      //       return Text(
                      //         'Level:  ${_authController.profile.value.level != null ? _authController.profile.value.level['level']['level'] : 0}',
                      //         style: const TextStyle(
                      //           color: AppColors.textPrimary,
                      //         ),
                      //       );
                      //     }),
                      //   ],
                      // ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/others/diamond.png',
                                width: 16,
                                height: 16,
                              ),
                              const SizedBox(width: 4),
                              Obx(
                                () => Text(
                                  '${_authController.profile.value.diamonds ?? 0}',
                                  style: const TextStyle(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Obx(
                            () => Text(
                              'ID ${_authController.profile.value.user?.uid}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Account', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                _ProfileActionTile(
                  onTap: () => Get.to(() => const EditProfileView()),
                  icon: LucideIcons.userRoundPen,
                  label: 'Edit Profile',
                ),
                Obx(() {
                  if (_authController.profile.value.login_type !=
                      'password_login') {
                    return Container();
                  }
                  return _ProfileActionTile(
                    onTap: () => Get.to(() => ChangePasswordView()),
                    icon: LucideIcons.lockKeyhole,
                    label: 'Change Password',
                  );
                }),
                Obx(
                  () => _ProfileActionTile(
                    onTap: () => Get.to(() => const BlockListView()),
                    icon: LucideIcons.userRoundX,
                    label:
                        'Block List: ${_authController.profile.value.blocks?.length ?? 0}',
                  ),
                ),
                _ProfileActionTile(
                  onTap: () => Get.to(
                    () => BroadcastingHistoriesView(
                      userId: _authController.profile.value.user!.uid!,
                      isAgentSearch: false,
                    ),
                  ),
                  icon: LucideIcons.history,
                  label: 'History',
                ),
                Obx(() {
                  if (!(_authController.profile.value.is_moderator ?? false)) {
                    return Container();
                  }
                  return _ProfileActionTile(
                    onTap: () => Get.to(() => ModeratorView()),
                    icon: LucideIcons.badgeCheck,
                    label: 'Moderator Activity',
                  );
                }),
                Obx(() {
                  if (!(_authController.profile.value.is_reseller ?? false)) {
                    return Container();
                  }
                  return _ProfileActionTile(
                    onTap: () => Get.to(() => ResellerView()),
                    icon: LucideIcons.diamond,
                    label: 'Reseller Recharge',
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Membership & wallet', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                _ProfileActionTile(
                  onTap: () => Get.to(() => const VVIPPackageView()),
                  icon: LucideIcons.crown,
                  label: 'VVIP Package',
                  iconColor: AppColors.premiumText,
                ),
                // ListTile(
                //   onTap: () => Get.to(() => const KingPackageView()),
                //   dense: true,
                //   leading: const Icon(Icons.workspace_premium),
                //   title: const Text(
                //     'King Package',
                //     style: TextStyle(fontSize: 16),
                //   ),
                //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                // ),
                _ProfileActionTile(
                  onTap: () => Get.to(() => const VIPPackageView()),
                  icon: LucideIcons.gem,
                  label: 'VIP Package',
                  iconColor: AppColors.premiumText,
                ),
                _ProfileActionTile(
                  onTap: () => Get.to(() => const EntryEffectPackageView()),
                  icon: LucideIcons.wandSparkles,
                  label: 'Entry Effect',
                  iconColor: AppColors.premiumText,
                ),
                !isAgent
                    ? Container()
                    : _ProfileActionTile(
                        onTap: () => Get.to(
                          () => HostsView(
                            agentUserId:
                                _authController.profile.value.user?.uid!,
                          ),
                        ),
                        icon: LucideIcons.usersRound,
                        label: 'Host List',
                      ),
                isAgent || isModerator || isReseller || isHost
                    ? Container()
                    : _ProfileActionTile(
                        onTap: () => Get.to(() => const HostRequstView()),
                        icon: LucideIcons.radioTower,
                        label: 'Host Request',
                      ),
                !isHost
                    ? Container()
                    : _ProfileActionTile(
                        onTap: () => Get.to(() => AgentForHostView()),
                        icon: LucideIcons.headset,
                        label: 'My Agent',
                      ),
                _ProfileActionTile(
                  onTap: () => Get.to(() => const WithdrawRequestsView()),
                  icon: LucideIcons.walletCards,
                  label: 'Withdraw Requests',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Support', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                // _ProfileActionTile(
                //   onTap: () async {
                //     String title = 'Welcome to ';
                //     String playStoreAppUrl =
                //         'https://play.google.com/store/apps/details?id=com.taksoft.doyel_live';
                //     String sharedText =
                //         'You Can Join With Us for Fun.......\n\n$playStoreAppUrl';
                //     await SharePlus.instance.share(
                //       ShareParams(text: sharedText, subject: title),
                //     );
                //   },
                //   icon: LucideIcons.share2,
                //   label: 'Share App',
                //   iconColor: AppColors.accent,
                // ),
                _ProfileActionTile(
                  onTap: () => Get.to(() => const FeedbackView()),
                  icon: LucideIcons.messageCircleQuestion,
                  label: 'Help & Feedback',
                  iconColor: AppColors.textSecondary,
                ),
                _ProfileActionTile(
                  onTap: () => Get.to(() => const PrivacyPolicyView()),
                  icon: LucideIcons.shieldCheck,
                  label: 'Privacy Policy',
                  iconColor: AppColors.textSecondary,
                ),
                _ProfileActionTile(
                  onTap: () => Get.to(() => const TermsAndConditionsView()),
                  icon: LucideIcons.scrollText,
                  label: 'Terms & Conditions',
                  iconColor: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Obx(() {
              final isSigningOut = _authController.authLoading.value;
              return _ProfileActionTile(
                onTap: isSigningOut ? null : () => _confirmSignOut(context),
                icon: LucideIcons.logOut,
                label: isSigningOut ? 'Logging out…' : 'Log Out',
                iconColor: AppColors.error,
                textColor: AppColors.error,
                isLoading: isSigningOut,
              );
            }),
          ),
        ],
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

    if (shouldSignOut == true) {
      _authController.tryToSignOut();
    }
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = AppColors.textSecondary,
    this.textColor = AppColors.textPrimary,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color textColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      minTileHeight: 64,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      horizontalTitleGap: 12,
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(12),
        ),
        child: isLoading
            ? SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: iconColor,
                ),
              )
            : Icon(icon, size: 21, color: iconColor),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15.5,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      trailing: isLoading
          ? null
          : Icon(LucideIcons.chevronRight, size: 19, color: iconColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
