import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/helper_functions/user_info_bottom_sheet_function.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ContributorsWidget extends StatefulWidget {
  const ContributorsWidget(
      {Key? key,
      required this.streamingController,
      required this.data,
      required this.onUpdateAction})
      : super(key: key);
  final LiveStreamingController streamingController;
  final Function onUpdateAction;
  final dynamic data;

  @override
  State<ContributorsWidget> createState() => _ContributorsWidgetState();
}

class _ContributorsWidgetState extends State<ContributorsWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.streamingController
        .loadContributionRankingList(userId: widget.data['uid']);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Padding(
        //   padding: EdgeInsets.only(left: 16.0),
        //   child: Text(
        //     'Top Contributors',
        //     style: TextStyle(
        //       color: Colors.grey,
        //       fontWeight: FontWeight.w700,
        //     ),
        //   ),
        // ),
        Obx(() {
          if (widget.streamingController.loadingContributionRankingList.value) {
            // Displaying LoadingSpinner to indicate waiting state
            return const Center(
              child: SpinKitHourGlass(
                color: Colors.red,
                size: 50.0,
              ),
            );
          }
// Extracting data from snapshot object
          final dataList = widget.streamingController.contributionRankingList;
          return SizedBox(
            height: 280,
            child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: dataList.length,
                itemBuilder: ((context, index) {
                  dynamic contribData = dataList[index];

                  return _contributorItem(
                    serialNumber: index + 1,
                    data: contribData,
                    onUpdateAction: widget.onUpdateAction,
                    // streamingController: streamingController,
                  );
                })),
          );
        }),
      ],
    );
  }
}

class _contributorItem extends StatelessWidget {
  const _contributorItem({
    Key? key,
    required this.serialNumber,
    required this.data,
    required this.onUpdateAction,
  }) : super(key: key);
  final int serialNumber;
  final dynamic data;
  final Function? onUpdateAction;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        showUserInfoBottomSheet(
            context: context,
            data: {
              ...data['contributor_profile'],
              'uid': data['contributor_profile']['user']['uid']
            },
            onUpdateAction: onUpdateAction!);
      },
      horizontalTitleGap: 0,
      // leading: Text(
      //   '$serialNumber',
      //   style: const TextStyle(
      //     fontSize: 16,
      //     fontWeight: FontWeight.w500,
      //     color: Colors.grey,
      //   ),
      // ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(children: [
              Positioned(
                top: 0,
                left: 0,
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: data['contributor_profile']['profile_image'] ==
                                  null &&
                              data['contributor_profile']['photo_url'] == null
                          ? Image.asset(
                              'assets/others/person.jpg',
                              width: 46,
                              height: 46,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: data['contributor_profile']
                                      ['profile_image'] ??
                                  data['contributor_profile']['photo_url'],
                              width: 46,
                              height: 46,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.red,
                                ),
                              ),
                            ),
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
                        borderRadius: BorderRadius.circular(100)),
                    child: Center(
                      child: Text(
                        '${data['contributor_profile']['level'] != null ? data['contributor_profile']['level']['level'] : 0}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  )),
            ]),
          ),
          const SizedBox(
            width: 8,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * .40),
                child: Text(
                  "${data['contributor_profile']['full_name']}",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                'assets/others/diamond.png',
                width: 16,
                height: 16,
              ),
              const SizedBox(
                width: 4,
              ),
              // Image.asset(
              //   'images/icons/coin.png',
              //   width: 16,
              //   fit: BoxFit.contain,
              // ),
              Text(
                '${data['diamonds']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
