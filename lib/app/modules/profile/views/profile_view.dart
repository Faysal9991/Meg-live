import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/auth/views/change_password_view.dart';
import 'package:doyel_live/app/modules/business/views/agent/agent_for_host_view.dart';
import 'package:doyel_live/app/modules/business/views/agent/hosts/hosts_view.dart';
import 'package:doyel_live/app/modules/business/views/host_requst_view.dart';
import 'package:doyel_live/app/modules/business/views/moderator/moderator_view.dart';
import 'package:doyel_live/app/modules/business/views/reseller/reseller_view.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                // color: Colors.black45,
                borderRadius: BorderRadius.circular(16.0),
                gradient: const LinearGradient(
                  colors: [Colors.black38, Colors.grey, Colors.black12],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: Obx(() {
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.0),
                              border: Border.all(
                                width: 2.0,
                                color: Colors.white,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              child:
                                  _authController.profile.value.profile_image ==
                                          null &&
                                      _authController.profile.value.photo_url ==
                                          null
                                  ? Image.asset(
                                      'assets/others/person.jpg',
                                      width:
                                          _authController
                                                  .profile
                                                  .value
                                                  .vvip_or_vip_preference['vvip_or_vip_gif'] !=
                                              null
                                          ? 60
                                          : 72,
                                      height:
                                          _authController
                                                  .profile
                                                  .value
                                                  .vvip_or_vip_preference['vvip_or_vip_gif'] !=
                                              null
                                          ? 60
                                          : 72,
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl:
                                          '${_authController.profile.value.profile_image ?? _authController.profile.value.photo_url}',
                                      width:
                                          _authController
                                                  .profile
                                                  .value
                                                  .vvip_or_vip_preference['vvip_or_vip_gif'] !=
                                              null
                                          ? 60
                                          : 72,
                                      height:
                                          _authController
                                                  .profile
                                                  .value
                                                  .vvip_or_vip_preference['vvip_or_vip_gif'] !=
                                              null
                                          ? 60
                                          : 72,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.red,
                                            ),
                                          ),
                                    ),
                            ),
                          ),
                          _authController
                                      .profile
                                      .value
                                      .vvip_or_vip_preference['vvip_or_vip_gif'] !=
                                  null
                              ? Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black38,
                                      // borderRadius: BorderRadius.only(
                                      //   bottomLeft: Radius.circular(20.0),
                                      //   bottomRight: Radius.circular(20.0),
                                      // ),
                                      border: Border.all(
                                        color: Colors.orange.shade600,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        100.0,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        100.0,
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: _authController
                                            .profile
                                            .value
                                            .vvip_or_vip_preference['vvip_or_vip_gif'],
                                        width: 40,
                                        height: 40,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(width: 8.0),
                  Column(
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
                              color: Colors.white,
                            ),
                          );
                        }),
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Obx(() {
                          return Text(
                            '${_authController.profile.value.user!.phone}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
                      //         color: Colors.white,
                      //       ),
                      //     ),
                      //     const SizedBox(
                      //       width: 16,
                      //     ),
                      //     Obx(() {
                      //       return Text(
                      //         'Level:  ${_authController.profile.value.level != null ? _authController.profile.value.level['level']['level'] : 0}',
                      //         style: const TextStyle(
                      //           color: Colors.white,
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
                              style: const TextStyle(color: Colors.white),
                            );
                          }),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.perm_identity,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Obx(() {
                            return Text(
                              '${_authController.profile.value.followers!.length}',
                              style: const TextStyle(color: Colors.white),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                //set border radius more than 50% of height and width to make circle
              ),
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
                    if (!_authController.profile.value.is_moderator!) {
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
                    if (!_authController.profile.value.is_reseller!) {
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
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                //set border radius more than 50% of height and width to make circle
              ),
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
                  !_authController.profile.value.is_agent!
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
                  _authController.profile.value.is_agent! ||
                          _authController.profile.value.is_moderator! ||
                          _authController.profile.value.is_reseller! ||
                          _authController.profile.value.is_host!
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
                  !_authController.profile.value.is_host!
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                //set border radius more than 50% of height and width to make circle
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: () async {
                      String title = 'Welcome to Doyel Live';
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
          ],
        ),
      ),
    );
  }
}
