import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/business/controllers/business_controller.dart';

class HostListView extends StatefulWidget {
  const HostListView({Key? key, this.agentUserId}) : super(key: key);
  final int? agentUserId;

  @override
  _HostListViewState createState() => _HostListViewState();
}

class _HostListViewState extends State<HostListView> {
  late AuthController _authController;
  late BusinessController _businessController;

  @override
  void initState() {
    super.initState();
    _authController = Get.find();
    _businessController = Get.find();
    _businessController.loadHostList(agentUserId: widget.agentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            return _businessController.loadingHostList.value
                ? const SpinKitCircle(
                    color: Colors.red,
                  )
                : _businessController.hostList.isEmpty
                    ? const Card(
                        elevation: 5,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "No host",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(
                              height: 8,
                            ),
                            Obx(() => Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Column(
                                    //   children: [
                                    //     Text('Hosts'),
                                    //     Text(
                                    //         '${_businessController.hostsCount.value}')
                                    //   ],
                                    // ),
                                    Text(
                                      'Hosts\n${_businessController.hostsCount.value}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      'Total Diamonds\n${_businessController.hostsGiftCoins.value}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      'Audio Diamonds\n${_businessController.hostsAudioGiftCoins.value}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      'Video Diamonds\n${_businessController.hostsVideoGiftCoins.value}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                )),
                            const SizedBox(
                              height: 8,
                            ),
                            Expanded(
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  dynamic hostData =
                                      _businessController.hostList[index];
                                  return Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 16.0,
                                    ),
                                    decoration: BoxDecoration(
                                      // color: Theme.of(context).primaryColor,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.grey,
                                          Colors.white,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Text(
                                              //     'Type: ${hostData['profile']['is_allow_video_live'] ? 'Video Live' : 'Audio Live'}'),
                                              Text(
                                                  'User ID: ${hostData['profile']['user']['uid']}'),
                                              Text(
                                                  'Name: ${hostData['profile']['full_name']}'),
                                              Text(
                                                  'Diamonds: ${hostData['profile']['diamonds']}'),
                                              Text(
                                                  'Be host at: ${DateFormat.yMEd().add_jms().format(DateTime.parse(hostData['profile']['be_host_datetime']).toLocal())}'),
                                            ],
                                          ),
                                        ),
                                        Obx(() {
                                          // if (!_businessController
                                          //         .allowHostRemove.value &&
                                          //     !_authController.profile.value
                                          //         .is_moderator!) {
                                          //   return Container();
                                          // }
                                          if (!_businessController
                                                  .allowHostRemove.value &&
                                              !_authController
                                                  .profile.value.is_agent!) {
                                            return Container();
                                          }
                                          return IconButton(
                                            onPressed: () {
                                              Get.defaultDialog(
                                                title:
                                                    'User ID: ${hostData['profile']['user']['uid']}',
                                                content: const Text(
                                                    'Do you wanna remove host?'),
                                                onConfirm: () {
                                                  _businessController
                                                      .tryToRemoveHost(
                                                    userId: hostData['profile']
                                                        ['user']['uid'],
                                                    profileData:
                                                        hostData['profile'],
                                                    agentUserId:
                                                        widget.agentUserId,
                                                  );
                                                  Navigator.of(context).pop();
                                                },
                                                confirmTextColor: Colors.white,
                                                onCancel: () => Get.close,
                                              );
                                            },
                                            icon: const Icon(Icons.close),
                                          );
                                        }),
                                      ],
                                    ),
                                  );
                                },
                                itemCount: _businessController.hostList.length,
                              ),
                            ),
                          ],
                        ),
                      );
          }),
        ],
      ),
    );
  }
}
