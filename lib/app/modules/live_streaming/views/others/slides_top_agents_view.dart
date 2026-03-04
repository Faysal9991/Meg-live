import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SlidesTopAgentsView extends StatefulWidget {
  const SlidesTopAgentsView({Key? key}) : super(key: key);

  @override
  _SlidesTopAgentsViewState createState() => _SlidesTopAgentsViewState();
}

class _SlidesTopAgentsViewState extends State<SlidesTopAgentsView> {
  late LiveStreamingController _livekitStreamingController;

  double _screenGlobalWidth = 0.0;
  List<Widget> listItemSlider = [];

  // Timer? _timer;

  @override
  void initState() {
    super.initState();
    _livekitStreamingController = Get.find();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _screenGlobalWidth = MediaQuery.of(context).size.width;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      if (_livekitStreamingController.topSlidingAgentRankingList.isNotEmpty) {
        listItemSlider = _livekitStreamingController.topSlidingAgentRankingList
            .asMap()
            // .take(5)
            .map((index, item) => MapEntry(
                index, _generatingScrollingView(data: item, serial: index + 1)))
            .values
            .toList();
        if (mounted) {
          setState(() {});
        }
      }
    });
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        // aspectRatio: 2.0,
        enlargeCenterPage: true,

        // /////////////
        // height: 50,
        aspectRatio: 16 / 5,
        viewportFraction: 0.8,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        // autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        // autoPlayCurve: Curves.easeIn,

        // enlargeCenterPage: true,
        enlargeFactor: 0.3,
        // onPageChanged: callbackFunction,
        scrollDirection: Axis.horizontal,
      ),
      items: listItemSlider,
    );
  }

  Widget _generatingScrollingView(
      {required dynamic data, required int serial}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Colors.black,
            Colors.green,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        // image: DecorationImage(
        //   image: AssetImage(
        //     'images/logos/doyel_live.png',
        //   ),
        // ),
      ),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            width: 16,
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: Stack(
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
                              child: CachedNetworkImage(
                                imageUrl: '${data['logo']}',
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .30,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Top: ${data['top']}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        data['is_app_owner']
                            ? const Text(
                                '🌟 App Owner',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ],
                ),
                Container(
                  constraints:
                      BoxConstraints(maxWidth: _screenGlobalWidth * .40),
                  child: Text(
                    data['agent_name'],
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'User ID: ${data['user_id']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // const Icon(
                        //   Icons.diamond,
                        //   color: Colors.blue,
                        //   size: 16,
                        // ),
                        Image.asset(
                          'assets/others/diamond.png',
                          height: 20,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          '${data['diamonds']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 16,
          ),
        ],
      ),
    );
  }
}
