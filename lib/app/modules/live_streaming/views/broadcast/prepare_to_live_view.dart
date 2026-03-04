import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/live_streaming_view.dart';
import 'package:doyel_live/app/widgets/circle_button.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';

class PrepareToLiveView extends StatefulWidget {
  const PrepareToLiveView({super.key, required this.camera});
  final CameraDescription? camera;

  @override
  _PrepareToLiveViewState createState() => _PrepareToLiveViewState();
}

class _PrepareToLiveViewState extends State<PrepareToLiveView> {
  late CameraController _cameraController;
  final AuthController _authController = Get.find();
  final LiveStreamingController _livekitStreamingController = Get.find();

  @override
  void initState() {
    super.initState();

    _cameraController = CameraController(
      widget.camera!,
      ResolutionPreset.max,
      enableAudio: false,
    );
    _cameraController
        .initialize()
        .then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        })
        .catchError((Object e) {
          if (e is CameraException) {
            switch (e.code) {
              case 'CameraAccessDenied':
                // print('User denied camera access.');
                break;
              default:
                // print('Handle other errors.');
                break;
            }
          }
        });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: const Color(0xFF273238),
          child: Stack(
            children: [
              Positioned(
                top: 54,
                left: 0,
                right: 0,
                bottom: 0,
                child: CameraPreview(_cameraController),
              ),
              Positioned(
                top: 58,
                left: 8,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/others/diamond.png',
                            width: 16,
                            height: 16,
                          ),
                          const SizedBox(width: 8),
                          Obx(() {
                            return Text(
                              '${_authController.profile.value.diamonds ?? 0}',
                              style: const TextStyle(color: Colors.white),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.visibility,
                            color: Colors.white,
                            size: 16.0,
                          ),
                          SizedBox(width: 8),
                          Text('0', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 4,
                left: 8,
                right: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              // borderRadius: BorderRadius.only(
                              //   bottomLeft: Radius.circular(20.0),
                              //   bottomRight: Radius.circular(20.0),
                              // ),
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            padding: const EdgeInsets.all(2.0),
                            child: Center(
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child:
                                      _authController
                                                  .profile
                                                  .value
                                                  .profile_image ==
                                              null &&
                                          _authController
                                                  .profile
                                                  .value
                                                  .photo_url ==
                                              null
                                      ? Image.asset(
                                          'assets/others/person.jpg',
                                          width: 28,
                                          height: 28,
                                          fit: BoxFit.cover,
                                        )
                                      : CachedNetworkImage(
                                          imageUrl:
                                              '${_authController.profile.value.profile_image ?? _authController.profile.value.photo_url}',
                                          width: 28,
                                          height: 28,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.red,
                                                    ),
                                              ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Obx(() {
                            return Text(
                              '${_authController.profile.value.full_name}',
                              overflow: TextOverflow.ellipsis,
                              // textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                // backgroundColor: Colors.black12,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    CircleButton(
                      icon: Icons.close,
                      iconSize: 32,
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(color: Colors.black38),
                  height: 100,
                  child: Center(
                    child: InkWell(
                      onTap: () async {
                        // Go to Live
                        _livekitStreamingController.setBroadcastStreamingStuffs(
                          brdchannelName:
                              '${_authController.profile.value.user!.uid!}',
                          broadcasterName:
                              _authController.profile.value.full_name,
                          brdImage:
                              _authController.profile.value.profile_image ??
                              _authController.profile.value.photo_url,
                          isBrdOwner: true,
                          activeInCalls: [],
                          brdViewers: [],
                          brdFollowers:
                              _authController.profile.value.followers ?? [],
                          brdBlocks: _authController.profile.value.blocks ?? [],
                          brdDiamonds:
                              _authController.profile.value.diamonds ?? 0,
                          brdLoveReacts: 0,
                          brdLevel: _authController.profile.value.level,
                          allowSend: true,
                        );
                        Get.off(
                          () => LiveStreamingView(
                            channelName: _authController
                                .profile
                                .value
                                .user!
                                .uid!
                                .toString(),
                            isBroadcaster: true,
                            fullName: _authController.profile.value.full_name,
                            profileImage:
                                _authController.profile.value.profile_image ??
                                _authController.profile.value.photo_url,
                            broadcasterDiamonds:
                                _authController.profile.value.diamonds ?? 0,
                            followers:
                                _authController.profile.value.followers ?? [],
                            blocks: _authController.profile.value.blocks ?? [],
                            level: _authController.profile.value.level,
                            vVipOrVipPreference: {
                              'vvip_or_vip_preference': _authController
                                  .profile
                                  .value
                                  .vvip_or_vip_preference,
                            },
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/others/go_live.png',
                        width: 150,
                        height: 54,
                      ),
                    ),
                  ),
                ),
                //   child: Center(
                //     child: rPrimaryElevatedButton(
                //       onPressed: () async {
                //         if (_busy) return;
                //       },
                //       primaryColor: Theme.of(context).primaryColor,
                //       buttonText: _busy ? 'Loading...' : 'Start LIVE',
                //       fontSize: 20,
                //       fixedSize: const Size(200, 40),
                //       fontWeight: FontWeight.w800,
                //     ),
                //   ),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
