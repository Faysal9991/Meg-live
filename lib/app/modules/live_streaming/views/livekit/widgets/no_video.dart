import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NoVideoWidget extends StatelessWidget {
  //
  const NoVideoWidget({Key? key, required this.data}) : super(key: key);
  final dynamic data;

  // @override
  // Widget build(BuildContext context) => Container(
  //       alignment: Alignment.center,
  //       child: LayoutBuilder(
  //         builder: (ctx, constraints) => Icon(
  //           EvaIcons.videoOffOutline,
  //           color: LKColors.lkBlue,
  //           size: math.min(constraints.maxHeight, constraints.maxWidth) * 0.3,
  //         ),
  //       ),
  //     );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: data['width'],
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black,
            Theme.of(context).primaryColor,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          data['level'] != null
              ? Container(
                  width: data['level']['frame_gif'] != null
                      ? data['width'] / 1.3
                      : null,
                  height: data['level']['frame_gif'] != null
                      ? data['width'] / 1.3
                      : null,
                  decoration: BoxDecoration(
                    image: data['level']['frame_gif'] != null
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(
                              data['level']['frame_gif'],
                            ),
                          )
                        : null,
                  ),
                  child: data['profile_image'] == null
                      ? Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.asset(
                              'assets/others/person.jpg',
                              width: (data['width'] / 3).round().toDouble(),
                              height: (data['width'] / 3).round().toDouble(),
                            ),
                          ),
                        )
                      : Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              imageUrl: data['profile_image'],
                              width: (data['width'] / 3).round().toDouble(),
                              height: (data['width'] / 3).round().toDouble(),
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.red)),
                            ),
                          ),
                        ),
                )
              : (data['profile_image'] == null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        'assets/others/person.jpg',
                        width: (data['width'] / 3).round().toDouble(),
                        height: (data['width'] / 3).round().toDouble(),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: CachedNetworkImage(
                        imageUrl: data['profile_image'],
                        width: (data['width'] / 3).round().toDouble(),
                        height: (data['width'] / 3).round().toDouble(),
                        placeholder: (context, url) => const Center(
                            child:
                                CircularProgressIndicator(color: Colors.red)),
                      ),
                    )),
          // serial == null
          //     ? const SizedBox(
          //         height: 8,
          //       )
          //     : Container(),
          // serial == null
          //     ? Text(
          //         data['full_name'],
          //         maxLines: 1,
          //         overflow: TextOverflow.ellipsis,
          //         style: const TextStyle(
          //           color: Colors.white,
          //           fontSize: 14,
          //         ),
          //       )
          //     : Container(),
        ],
      ),
    );
  }
}
