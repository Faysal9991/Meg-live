import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/data/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/profile/controllers/profile_controller.dart';

class BlockListView extends StatefulWidget {
  const BlockListView({Key? key}) : super(key: key);

  @override
  _BlockListViewState createState() => _BlockListViewState();
}

class _BlockListViewState extends State<BlockListView> {
  final ProfileController _profileController = Get.find();
  final AuthController _authController = Get.find();
  // final LiveStreamingFirebaseStuffs _liveStreamingFirebaseStuffs =
  //     LiveStreamingFirebaseStuffs();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _profileController.fecthBlockList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(
        () => LoadingOverlay(
          isLoading: _profileController.listLoading.value,
          progressIndicator: SpinKitHourGlass(
            color: Theme.of(context).primaryColor,
            size: 50.0,
          ),
          child: Scaffold(
            appBar: AppBar(title: const Text('Block List'), centerTitle: true),
            body: Obx(
              () => _profileController.listBlockWithProfile.isEmpty
                  ? const Center(
                      child: Text(
                        'No block',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.separated(
                        // padding: EdgeInsets.zero,
                        physics: const ClampingScrollPhysics(),
                        itemCount:
                            _profileController.listBlockWithProfile.length,
                        itemBuilder: (context, index) {
                          dynamic data =
                              _profileController.listBlockWithProfile[index];
                          return BlockItem(
                            data: data['profile'],
                            profileController: _profileController,
                            authController: _authController,
                            // liveStreamingFirebaseStuffs:
                            //     _liveStreamingFirebaseStuffs,
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: 1);
                        },
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class BlockItem extends StatelessWidget {
  const BlockItem({
    Key? key,
    this.data,
    required this.profileController,
    required this.authController,
    // required this.liveStreamingFirebaseStuffs,
  }) : super(key: key);
  final dynamic data;
  final ProfileController profileController;
  final AuthController authController;
  // final LiveStreamingFirebaseStuffs liveStreamingFirebaseStuffs;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // color: Theme.of(context).primaryColor.withOpacity(.5),
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(.5),
            Theme.of(context).primaryColor.withOpacity(.5),
            Colors.black38,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        // onTap: () => showUserInfoBottomSheet(
        //     context: context, data: data, onUpdateAction: onUpdateAction!),
        horizontalTitleGap: 0,

        leading: SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child:
                    data['profile_image'] == null && data['photo_url'] == null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: Image.asset(
                          'assets/others/person.jpg',
                          width: 46,
                          height: 46,
                          fit: BoxFit.cover,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: CachedNetworkImage(
                          imageUrl: data['profile_image'] ?? data['photo_url'],
                          width: 46,
                          height: 46,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(color: Colors.red),
                          ),
                        ),
                      ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      '${data['level'] != null ? data['level']['level'] : 0}',
                      style: const TextStyle(color: Colors.white, fontSize: 8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          "${data['full_name']}",
          // overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            // color: Colors.white,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () async {
            if (profileController.loadingPerformBlock.value ==
                data['user']['uid']) {
              return;
            }
            List<dynamic> blocks = await profileController.performBlock(
              uid: data['user']['uid'],
            );

            Profile profile = authController.profile.value;
            profile.blocks = blocks;
            authController.profile.value = Profile();
            authController.profile.value = profile;
            authController.preferences.setString(
              'profile',
              jsonEncode(profile.toJson()),
            );
            profileController.setRemoveFromBlockList(uid: data['user']['uid']);
            // liveStreamingFirebaseStuffs.updateBroadcasterBlocks(
            //     channelName: authController.profile.value.user!.uid!,
            //     blocks: blocks);
          },
          child: Obx(() {
            return profileController.loadingPerformBlock.value !=
                    data['user']['uid']
                ? const Text('Unblock')
                : const CircularProgressIndicator(color: Colors.red);
          }),
        ),
      ),
    );
  }
}
