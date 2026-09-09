import 'package:doyel_live/app/theme/app_neumorphic_styles.dart';
import 'package:doyel_live/app/widgets/app_design_widgets.dart';
import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/business/controllers/business_controller.dart';
import 'package:doyel_live/app/modules/business/views/agent/hosts/hosts_view.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';

class HostRequstView extends StatefulWidget {
  const HostRequstView({Key? key}) : super(key: key);

  @override
  _HostRequstViewState createState() => _HostRequstViewState();
}

class _HostRequstViewState extends State<HostRequstView> {
  late BusinessController _businessController;
  late AuthController _authController;

  late TextEditingController _editingControllerSearchUid;

  @override
  void initState() {
    super.initState();
    _businessController = Get.put(BusinessController());
    _authController = Get.find();
    _editingControllerSearchUid = TextEditingController();
    _businessController.loadAgentListForHostRequest();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _authController.profile.value.is_moderator!
                ? 'Agents'
                : 'Host Request',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(() {
                return _businessController.loadingAgentList.value ||
                        _businessController.loadingHostRequest.value
                    ? const SpinKitCircle(color: AppColors.error)
                    : _businessController.hostRequestedData.value['id'] != null
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            AppCard(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  "Your host request (${_businessController.hostRequestedData.value['is_allow_video_live'] ? 'Video Live' : 'Audio Live'}) is pending. Please wait for authority confirmation.\n\nDatetime: ${DateFormat.yMEd().add_jms().format(DateTime.parse(_businessController.hostRequestedData.value['datetime']).toLocal())}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.warning,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            rPrimaryElevatedIconButton(
                              onPressed: () {
                                Get.defaultDialog(
                                  title: 'Host Request',
                                  content: const Text(
                                    'Do you wanna remove host request?',
                                  ),
                                  onConfirm: () {
                                    _businessController
                                        .tryToRemoveHostRequest();
                                    Navigator.of(context).pop();
                                  },
                                  confirmTextColor: AppColors.surface,
                                  onCancel: () => Get.close,
                                );
                              },
                              primaryColor: AppColors.error,
                              buttonText: 'Remove Request',
                              fontSize: 16,
                              iconData: Icons.close,
                            ),
                          ],
                        ),
                      )
                    : _businessController.agentListForHost.isEmpty
                    ? const AppCard(
                        elevation: 5,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "No agent available now",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            rPrimaryTextField(
                              controller: _editingControllerSearchUid,
                              keyboardType: TextInputType.number,
                              borderColor: Theme.of(context).primaryColor,
                              hintText: 'Search agent with UserID here',
                              useNeumorphic: true,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  if (_businessController
                                      .loadingAgentSearch
                                      .value) {
                                    rShowSnackBar(
                                      context: context,
                                      title: 'You already searching an agent',
                                      color: AppColors.warning,
                                    );
                                    return;
                                  }
                                  if (_businessController
                                      .loadingHostRequest
                                      .value) {
                                    rShowSnackBar(
                                      context: context,
                                      title: 'Host request is processing...',
                                      color: AppColors.warning,
                                    );
                                    return;
                                  }
                                  try {
                                    int uid = int.parse(
                                      _editingControllerSearchUid.text,
                                    );
                                    if (uid > 0) {
                                      _editingControllerSearchUid.clear();
                                      _businessController.tryToSearchAgent(
                                        userId: uid,
                                      );
                                    }
                                  } catch (e) {
                                    rShowSnackBar(
                                      context: context,
                                      title: 'You must enter number for UserID',
                                      color: AppColors.warning,
                                      durationInSeconds: 2,
                                    );
                                  }
                                },
                                icon: const Icon(Icons.search),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Obx(() {
                              if (_businessController
                                  .loadingAgentSearch
                                  .value) {
                                return const SpinKitCircle(
                                  color: AppColors.error,
                                );
                              }
                              if (_businessController
                                      .searchedAgentData
                                      .value['user_id'] ==
                                  null) {
                                return Container();
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'You searched:',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 16.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if (_authController
                                            .profile
                                            .value
                                            .is_moderator!) {
                                          Get.to(
                                            () => HostsView(
                                              agentUserId: _businessController
                                                  .searchedAgentData
                                                  .value['user_id'],
                                            ),
                                          );
                                          return;
                                        }
                                        Get.defaultDialog(
                                          title:
                                              'Agent User ID: ${_businessController.searchedAgentData.value['user_id']}',
                                          content: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              const Text(
                                                'Do you wanna send host request to this Agent?',
                                              ),
                                              const Text(
                                                'Choose Live Type:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              rPrimaryElevatedIconButton(
                                                onPressed: () {
                                                  _businessController
                                                      .tryToSendHostRequest(
                                                        agentId: _businessController
                                                            .searchedAgentData
                                                            .value['user_id'],
                                                        liveType: 'video',
                                                      );
                                                  Get.back();
                                                },
                                                primaryColor: AppColors.error,
                                                buttonText: 'Video Live',
                                                fontSize: 16,
                                                iconData:
                                                    Icons.camera_alt_outlined,
                                              ),
                                            ],
                                          ),
                                          // onConfirm: () {
                                          //   _businessController
                                          //       .tryToSendHostRequest(
                                          //           agentId: agentData['user_id']);
                                          //   Get.back();
                                          // },
                                          // confirmTextColor: AppColors.surface,
                                          onCancel: () => Get.close,
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Agent User ID: ${_businessController.searchedAgentData.value['user_id']}',
                                                ),
                                                Text(
                                                  'Name: ${_businessController.searchedAgentData.value['agent_name']}',
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.touch_app),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Divider(color: AppColors.textSecondary),
                                  const SizedBox(height: 4),
                                ],
                              );
                            }),
                            Expanded(
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  dynamic agentData = _businessController
                                      .agentListForHost[index];
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 16.0,
                                    ),
                                    decoration: AppNeumorphicStyles.decoration(),
                                    child: InkWell(
                                      onTap: () {
                                        // if (_authController.profile.value
                                        //     .is_moderator!) {
                                        //   Get.to(
                                        //     () => HostsView(
                                        //       agentUserId:
                                        //           agentData['user_id'],
                                        //     ),
                                        //   );
                                        //   return;
                                        // }
                                        Get.defaultDialog(
                                          title:
                                              'Agent User ID: ${agentData['user_id']}',
                                          content: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              const Text(
                                                'Do you wanna send host request to this Agent?',
                                              ),
                                              const Text(
                                                'Choose Live Type:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              rPrimaryElevatedIconButton(
                                                onPressed: () {
                                                  _businessController
                                                      .tryToSendHostRequest(
                                                        agentId:
                                                            agentData['user_id'],
                                                        liveType: 'video',
                                                      );
                                                  Get.back();
                                                },
                                                primaryColor: AppColors.error,
                                                buttonText: 'Video Live',
                                                fontSize: 16,
                                                iconData:
                                                    Icons.camera_alt_outlined,
                                              ),
                                            ],
                                          ),
                                          // onConfirm: () {
                                          //   _businessController
                                          //       .tryToSendHostRequest(
                                          //           agentId: agentData['user_id']);
                                          //   Get.back();
                                          // },
                                          // confirmTextColor: AppColors.surface,
                                          onCancel: () => Get.close,
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Agent User ID: ${agentData['user_id']}',
                                                ),
                                                // Text(
                                                //     'Contact: ${agentData['mobile_number']}'),
                                                Text(
                                                  'Name: ${agentData['agent_name']}',
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.touch_app),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                itemCount:
                                    _businessController.agentListForHost.length,
                              ),
                            ),
                          ],
                        ),
                      );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_authController.profile.value.is_moderator!
//             ? 'Agents'
//             : 'Host Request'),
//       ),
//       body: Material(
//         textStyle: const TextStyle(
//           color: AppColors.textPrimary,
//         ),
//         color: Colors.transparent,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Obx(() {
//                 return _businessController.loadingAgentList.value ||
//                         _businessController.loadingHostRequest.value
//                     ? const SpinKitCircle(
//                         color: AppColors.error,
//                       )
//                     : _businessController.hostRequestedData.value['id'] != null
//                         ? Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Column(
//                               children: [
//                                 Card(
//                                   elevation: 5,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(16.0),
//                                     child: Text(
//                                       "Your host request (${_businessController.hostRequestedData.value['is_allow_video_live'] ? 'Video Live' : 'Audio Live'}) is pending. Please wait for authority confirmation.\n\nDatetime: ${DateFormat.yMEd().add_jms().format(DateTime.parse(_businessController.hostRequestedData.value['datetime']).toLocal())}",
//                                       textAlign: TextAlign.center,
//                                       style: const TextStyle(
//                                         color: AppColors.warning,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   height: 16,
//                                 ),
//                                 rPrimaryElevatedIconButton(
//                                   onPressed: () {
//                                     Get.defaultDialog(
//                                       title: 'Host Request',
//                                       content: const Text(
//                                           'Do you wanna remove host request?'),
//                                       onConfirm: () {
//                                         _businessController
//                                             .tryToRemoveHostRequest();
//                                         Navigator.of(context).pop();
//                                       },
//                                       confirmTextColor: AppColors.surface,
//                                       onCancel: () =>
//                                           Navigator.of(context).pop(),
//                                     );
//                                   },
//                                   primaryColor: AppColors.error,
//                                   buttonText: 'Remove Request',
//                                   fontSize: 16,
//                                   iconData: Icons.close,
//                                 ),
//                               ],
//                             ),
//                           )
//                         : _businessController.agentListForHost.isEmpty
//                             ? const Card(
//                                 elevation: 5,
//                                 child: Padding(
//                                   padding: EdgeInsets.all(16.0),
//                                   child: Text(
//                                     "No agent available now",
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                       color: AppColors.warning,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             : Expanded(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment.stretch,
//                                   children: [
//                                     rPrimaryTextField(
//                                       controller: _editingControllerSearchUid,
//                                       keyboardType: TextInputType.number,
//                                       borderColor:
//                                           Theme.of(context).primaryColorLight,
//                                       hintText: 'Search user with UserID here',
//                                       suffixIcon: IconButton(
//                                         onPressed: () {
//                                           FocusScope.of(context).unfocus();
//                                           if (_businessController
//                                               .loadingAgentSearch.value) {
//                                             rShowSnackBar(
//                                               context: context,
//                                               title:
//                                                   'You already searching a user',
//                                               color: AppColors.warning,
//                                             );
//                                             return;
//                                           }
//                                           if (_businessController
//                                               .loadingHostRequest.value) {
//                                             rShowSnackBar(
//                                               context: context,
//                                               title:
//                                                   'Host request is processing...',
//                                               color: AppColors.warning,
//                                             );
//                                             return;
//                                           }
//                                           try {
//                                             int uid = int.parse(
//                                                 _editingControllerSearchUid
//                                                     .text);
//                                             if (uid > 0) {
//                                               _editingControllerSearchUid
//                                                   .clear();
//                                               _businessController
//                                                   .tryToSearchAgent(
//                                                       userId: uid);
//                                             }
//                                           } catch (e) {
//                                             rShowSnackBar(
//                                               context: context,
//                                               title:
//                                                   'You must enter number for UserID',
//                                               color: AppColors.warning,
//                                               durationInSeconds: 2,
//                                             );
//                                           }
//                                         },
//                                         icon: const Icon(
//                                           Icons.search,
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       height: 16,
//                                     ),
//                                     Obx(() {
//                                       if (_businessController
//                                           .loadingAgentSearch.value) {
//                                         return const SpinKitCircle(
//                                           color: AppColors.error,
//                                         );
//                                       }
//                                       if (_businessController
//                                               .searchedAgentData.value['user_id'] ==
//                                           null) {
//                                         return Container();
//                                       }
//                                       return Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           const Text('You searched:'),
//                                           const SizedBox(
//                                             height: 4,
//                                           ),
//                                           Material(
//                                             textStyle: const TextStyle(
//                                               color: AppColors.surface,
//                                             ),
//                                             color: Colors.transparent,
//                                             child: Container(
//                                               margin:
//                                                   const EdgeInsets.symmetric(
//                                                       vertical: 2),
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                 vertical: 8.0,
//                                                 horizontal: 16.0,
//                                               ),
//                                               decoration: BoxDecoration(
//                                                 // color: Theme.of(context)
//                                                 //     .primaryColorLight,
//                                                 gradient: LinearGradient(
//                                                   colors: [
//                                                     AppColors.textPrimary,
//                                                     Theme.of(context)
//                                                         .primaryColor,
//                                                   ],
//                                                   begin: Alignment.bottomLeft,
//                                                   end: Alignment.topRight,
//                                                 ),
//                                                 borderRadius:
//                                                     BorderRadius.circular(20.0),
//                                               ),
//                                               child: InkWell(
//                                                 onTap: () {
//                                                   Get.defaultDialog(
//                                                     title:
//                                                         'Agent User ID: ${_businessController.searchedAgentData.value['user']}',
//                                                     content: Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .stretch,
//                                                       children: [
//                                                         const Text(
//                                                             'Do you wanna send host request to this Agent?'),
//                                                         const Text(
//                                                           'Choose Live Type:',
//                                                           style: TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                           ),
//                                                         ),
//                                                         const SizedBox(
//                                                           height: 16,
//                                                         ),
//                                                         rPrimaryElevatedIconButton(
//                                                           onPressed: () {
//                                                             _businessController
//                                                                 .tryToSendHostRequest(
//                                                               agentId: _businessController
//                                                                   .searchedAgentData
//                                                                   .value['user_id'],
//                                                               liveType: 'audio',
//                                                             );
//                                                             Get.back();
//                                                           },
//                                                           primaryColor:
//                                                               AppColors.success,
//                                                           buttonText:
//                                                               'Audio Live',
//                                                           fontSize: 16,
//                                                           iconData: Icons
//                                                               .audiotrack_outlined,
//                                                         ),
//                                                         const SizedBox(
//                                                           height: 8,
//                                                         ),
//                                                         rPrimaryElevatedIconButton(
//                                                           onPressed: () {
//                                                             _businessController
//                                                                 .tryToSendHostRequest(
//                                                               agentId: _businessController
//                                                                   .searchedAgentData
//                                                                   .value['user_id'],
//                                                               liveType: 'video',
//                                                             );
//                                                             Get.back();
//                                                           },
//                                                           primaryColor:
//                                                               AppColors.error,
//                                                           buttonText:
//                                                               'Video Live',
//                                                           fontSize: 16,
//                                                           iconData: Icons
//                                                               .camera_alt_outlined,
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     // onConfirm: () {
//                                                     //   _businessController
//                                                     //       .tryToSendHostRequest(
//                                                     //           agentId: agentData['user_id']);
//                                                     //   Get.back();
//                                                     // },
//                                                     // confirmTextColor: AppColors.surface,
//                                                     onCancel: () => Get.back(),
//                                                   );
//                                                 },
//                                                 child: Row(
//                                                   children: [
//                                                     Expanded(
//                                                       child: Column(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: [
//                                                           Text(
//                                                               'Agent User ID: ${_businessController.searchedAgentData.value['user']}'),
//                                                           Text(
//                                                               'Name: ${_businessController.searchedAgentData.value['profile']['full_name']}'),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                     const Icon(Icons.touch_app),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           const SizedBox(
//                                             height: 4,
//                                           ),
//                                           const Divider(
//                                             color: AppColors.surface,
//                                           ),
//                                           const SizedBox(
//                                             height: 4,
//                                           ),
//                                         ],
//                                       );
//                                     }),
//                                     Expanded(
//                                       child: ListView.builder(
//                                         physics: const BouncingScrollPhysics(),
//                                         shrinkWrap: true,
//                                         itemBuilder: (context, index) {
//                                           dynamic agentData =
//                                               _businessController
//                                                   .agentListForHost[index];
//                                           return Material(
//                                             textStyle: const TextStyle(
//                                               color: AppColors.surface,
//                                             ),
//                                             color: Colors.transparent,
//                                             child: Container(
//                                               margin:
//                                                   const EdgeInsets.symmetric(
//                                                       vertical: 2),
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                 vertical: 8.0,
//                                                 horizontal: 16.0,
//                                               ),
//                                               decoration: BoxDecoration(
//                                                 // color: Theme.of(context)
//                                                 //     .primaryColorLight,
//                                                 gradient: LinearGradient(
//                                                   colors: [
//                                                     AppColors.textPrimary,
//                                                     Theme.of(context)
//                                                         .primaryColor,
//                                                   ],
//                                                   begin: Alignment.bottomLeft,
//                                                   end: Alignment.topRight,
//                                                 ),
//                                                 borderRadius:
//                                                     BorderRadius.circular(20.0),
//                                               ),
//                                               child: InkWell(
//                                                 onTap: () {
//                                                   Get.defaultDialog(
//                                                     title:
//                                                         'Agent User ID: ${agentData['user']}',
//                                                     content: Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .stretch,
//                                                       children: [
//                                                         const Text(
//                                                             'Do you wanna send host request to this Agent?'),
//                                                         const Text(
//                                                           'Choose Live Type:',
//                                                           style: TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                           ),
//                                                         ),
//                                                         const SizedBox(
//                                                           height: 16,
//                                                         ),
//                                                         rPrimaryElevatedIconButton(
//                                                           onPressed: () {
//                                                             _businessController
//                                                                 .tryToSendHostRequest(
//                                                               agentId:
//                                                                   agentData[
//                                                                       'user_id'],
//                                                               liveType: 'audio',
//                                                             );
//                                                             Get.back();
//                                                           },
//                                                           primaryColor:
//                                                               AppColors.success,
//                                                           buttonText:
//                                                               'Audio Live',
//                                                           fontSize: 16,
//                                                           iconData: Icons
//                                                               .audiotrack_outlined,
//                                                         ),
//                                                         const SizedBox(
//                                                           height: 8,
//                                                         ),
//                                                         rPrimaryElevatedIconButton(
//                                                           onPressed: () {
//                                                             _businessController
//                                                                 .tryToSendHostRequest(
//                                                               agentId:
//                                                                   agentData[
//                                                                       'user_id'],
//                                                               liveType: 'video',
//                                                             );
//                                                             Get.back();
//                                                           },
//                                                           primaryColor:
//                                                               AppColors.error,
//                                                           buttonText:
//                                                               'Video Live',
//                                                           fontSize: 16,
//                                                           iconData: Icons
//                                                               .camera_alt_outlined,
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     // onConfirm: () {
//                                                     //   _businessController
//                                                     //       .tryToSendHostRequest(
//                                                     //           agentId: agentData['user_id']);
//                                                     //   Get.back();
//                                                     // },
//                                                     // confirmTextColor: AppColors.surface,
//                                                     onCancel: () => Get.back(),
//                                                   );
//                                                 },
//                                                 child: Row(
//                                                   children: [
//                                                     Expanded(
//                                                       child: Column(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: [
//                                                           Text(
//                                                               'Agent User ID: ${agentData['user']}'),
//                                                           // Text(
//                                                           //     'Contact: ${agentData['mobile_number']}'),
//                                                           Text(
//                                                               'Name: ${agentData['profile']['full_name']}'),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                     const Icon(Icons.touch_app),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                         itemCount: _businessController
//                                             .agentListForHost.length,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//               }),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
