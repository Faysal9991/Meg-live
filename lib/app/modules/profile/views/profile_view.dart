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
import 'package:doyel_live/app/modules/products/views/king_package_view.dart';
import 'package:doyel_live/app/modules/products/views/vip_package_view.dart';
import 'package:doyel_live/app/modules/products/views/vvip_package_view.dart';
import 'package:doyel_live/app/modules/profile/views/block_list_view.dart';
import 'package:doyel_live/app/modules/profile/views/broadcasting_histories.dart';
import 'package:doyel_live/app/modules/profile/views/edit_profile_view.dart';
import 'package:doyel_live/app/modules/profile/views/info/privacy_policy_view.dart';
import 'package:doyel_live/app/modules/profile/views/info/terms_and_conditions_view.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({Key? key}) : super(key: key);
  final AuthController _authController = Get.find();
  @override
  Widget build(BuildContext context) {
    final profile = _authController.profile.value;
    final isAgent = profile.is_agent ?? false;
    final isModerator = profile.is_moderator ?? false;
    final isReseller = profile.is_reseller ?? false;
    final isHost = profile.is_host ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.xs,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Profile', style: AppTextStyles.pageTitle),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                // color: AppColors.overlayStrong,
                borderRadius: BorderRadius.circular(16.0),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primaryDark,
                    AppColors.primary,
                    AppColors.accentDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
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
                                fontWeight: FontWeight.w600,
                                color: AppColors.surface,
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
                                color: AppColors.surface,
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
                        //         color: AppColors.surface,
                        //       ),
                        //     ),
                        //     const SizedBox(
                        //       width: 16,
                        //     ),
                        //     Obx(() {
                        //       return Text(
                        //         'Level:  ${_authController.profile.value.level != null ? _authController.profile.value.level['level']['level'] : 0}',
                        //         style: const TextStyle(
                        //           color: AppColors.surface,
                        //         ),
                        //       );
                        //     }),
                        //   ],
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/others/diamond.png',
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 4),
                            Obx(() {
                              return Text(
                                '${_authController.profile.value.diamonds ?? 0}',
                                style: const TextStyle(
                                  color: AppColors.surface,
                                ),
                              );
                            }),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.perm_identity,
                              color: AppColors.surface,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Obx(() {
                              return Text(
                                '${_authController.profile.value.user?.uid}',
                                style: const TextStyle(
                                  color: AppColors.surface,
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    onTap: () => Get.to(() => const EditProfileView()),
                    dense: true,
                    leading: const Icon(Icons.settings),
                    title: const Text(
                      'Edit Profile',
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  Obx(() {
                    if (_authController.profile.value.login_type !=
                        'password_login') {
                      return Container();
                    }
                    return ListTile(
                      onTap: () => Get.to(() => ChangePasswordView()),
                      dense: true,
                      leading: const Icon(Icons.password),
                      title: const Text(
                        'Change Password',
                        style: TextStyle(fontSize: 18),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    );
                  }),
                  Obx(
                    () => ListTile(
                      onTap: () => Get.to(() => const BlockListView()),
                      dense: true,
                      leading: const Icon(Icons.no_accounts_rounded),
                      title: Text(
                        'Block List: ${_authController.profile.value.blocks!.length}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ),
                  ListTile(
                    onTap: () => Get.to(
                      () => BroadcastingHistoriesView(
                        userId: _authController.profile.value.user!.uid!,
                        isAgentSearch: false,
                      ),
                    ),
                    dense: true,
                    leading: Icon(MdiIcons.history),
                    title: const Text(
                      'History',
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  Obx(() {
                    if (!(_authController.profile.value.is_moderator ??
                        false)) {
                      return Container();
                    }
                    return ListTile(
                      onTap: () => Get.to(() => ModeratorView()),
                      dense: true,
                      leading: const Icon(Icons.local_activity),
                      title: const Text(
                        'Moderator Activity',
                        style: TextStyle(fontSize: 18),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    );
                  }),
                  Obx(() {
                    if (!(_authController.profile.value.is_reseller ?? false)) {
                      return Container();
                    }
                    return ListTile(
                      onTap: () => Get.to(() => ResellerView()),
                      dense: true,
                      leading: Icon(MdiIcons.diamond),
                      title: const Text(
                        'Reseller Recharge',
                        style: TextStyle(fontSize: 18),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    onTap: () => Get.to(() => const VVIPPackageView()),
                    dense: true,
                    leading: const Icon(Icons.important_devices),
                    title: const Text(
                      'VVIP Package',
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  // ListTile(
                  //   onTap: () => Get.to(() => const KingPackageView()),
                  //   dense: true,
                  //   leading: const Icon(Icons.workspace_premium),
                  //   title: const Text(
                  //     'King Package',
                  //     style: TextStyle(fontSize: 18),
                  //   ),
                  //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  // ),
                  ListTile(
                    onTap: () => Get.to(() => const VIPPackageView()),
                    dense: true,
                    leading: const Icon(Icons.important_devices_rounded),
                    title: const Text(
                      'VIP Package',
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  ListTile(
                    onTap: () => Get.to(() => const EntryEffectPackageView()),
                    dense: true,
                    leading: const Icon(Icons.auto_awesome_motion),
                    title: const Text(
                      'Entry Effect',
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  !isAgent
                      ? Container()
                      : ListTile(
                          onTap: () => Get.to(
                            () => HostsView(
                              agentUserId:
                                  _authController.profile.value.user?.uid!,
                            ),
                          ),
                          dense: true,
                          leading: const Icon(Icons.groups),
                          title: const Text(
                            'Host List',
                            style: TextStyle(fontSize: 18),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                        ),
                  isAgent || isModerator || isReseller || isHost
                      ? Container()
                      : ListTile(
                          onTap: () => Get.to(() => const HostRequstView()),
                          dense: true,
                          leading: const Icon(Icons.broadcast_on_home),
                          title: const Text(
                            'Host Request',
                            style: TextStyle(fontSize: 18),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                        ),
                  !isHost
                      ? Container()
                      : ListTile(
                          onTap: () => Get.to(() => AgentForHostView()),
                          dense: true,
                          leading: const Icon(Icons.support_agent),
                          title: const Text(
                            'My Agent',
                            style: TextStyle(fontSize: 18),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                        ),
                  ListTile(
                    onTap: () => Get.to(() => const WithdrawRequestsView()),
                    dense: true,
                    leading: const Icon(Icons.account_balance_wallet_outlined),
                    title: const Text(
                      'Withdraw Requests',
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    onTap: () async {
                      String title = 'Welcome to ';
                      String playStoreAppUrl =
                          'https://play.google.com/store/apps/details?id=com.taksoft.doyel_live';
                      String sharedText =
                          'You Can Join With Us for Fun.......\n\n$playStoreAppUrl';
                      await SharePlus.instance.share(
                        ShareParams(text: sharedText, subject: title),
                      );
                    },
                    dense: true,
                    leading: const Icon(Icons.share),
                    title: const Text(
                      'Share App',
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  ListTile(
                    onTap: () {
                      final Uri emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: 'toplive46@gmail.com',
                      );

                      launchUrl(emailLaunchUri);
                    },
                    dense: true,
                    leading: Icon(MdiIcons.help),
                    title: const Text(
                      'Help & Feedback',
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  ListTile(
                    onTap: () => Get.to(() => const PrivacyPolicyView()),
                    dense: true,
                    leading: Icon(MdiIcons.fileDocument),
                    title: const Text(
                      'Privacy Policy',
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  ListTile(
                    onTap: () => Get.to(() => const TermsAndConditionsView()),
                    dense: true,
                    leading: Icon(MdiIcons.fileDocument),
                    title: const Text(
                      'Terms & Conditions',
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Obx(() {
                final isSigningOut = _authController.authLoading.value;
                return ListTile(
                  onTap: isSigningOut ? null : () => _confirmSignOut(context),
                  dense: true,
                  leading: isSigningOut
                      ? const SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.error,
                          ),
                        )
                      : const Icon(
                          Icons.logout_rounded,
                          color: AppColors.error,
                        ),
                  title: Text(
                    isSigningOut ? 'Logging out…' : 'Log Out',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  trailing: isSigningOut
                      ? null
                      : const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.error,
                        ),
                );
              }),
            ),
          ],
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
              foregroundColor: AppColors.onPrimary,
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
