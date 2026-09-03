import 'package:doyel_live/app/theme/app_colors.dart';
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
    final profileImage = data['profile_image']?.toString().trim() ?? '';
    return Container(
      width: data['width'],
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.textPrimary, Theme.of(context).primaryColor],
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
                  child: profileImage.isEmpty
                      ? Center(
                          child: ClipOval(
                            child: Image.asset(
                              'assets/others/person.jpg',
                              width: (data['width'] / 3).round().toDouble(),
                              height: (data['width'] / 3).round().toDouble(),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Center(
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: profileImage,
                              width: (data['width'] / 3).round().toDouble(),
                              height: (data['width'] / 3).round().toDouble(),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.error,
                                ),
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/others/person.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                )
              : (profileImage.isEmpty
                    ? ClipOval(
                        child: Image.asset(
                          'assets/others/person.jpg',
                          width: (data['width'] / 3).round().toDouble(),
                          height: (data['width'] / 3).round().toDouble(),
                          fit: BoxFit.cover,
                        ),
                      )
                    : ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: profileImage,
                          width: (data['width'] / 3).round().toDouble(),
                          height: (data['width'] / 3).round().toDouble(),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.error,
                            ),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/others/person.jpg',
                            fit: BoxFit.cover,
                          ),
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
          //           color: AppColors.surface,
          //           fontSize: 14,
          //         ),
          //       )
          //     : Container(),
        ],
      ),
    );
  }
}
