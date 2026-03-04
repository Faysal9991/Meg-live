import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTabBar extends StatelessWidget {
  final List<IconData> icons;
  final int selectedIndex;
  final Function(int) onTap;
  final bool isBottomIndicator;

  const CustomTabBar({
    Key? key,
    required this.icons,
    required this.selectedIndex,
    required this.onTap,
    this.isBottomIndicator = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      indicatorPadding: EdgeInsets.zero,
      indicator: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.transparent, width: 0.0),
        ),
      ),
      padding: EdgeInsets.zero,
      labelPadding: EdgeInsets.zero,
      // indicator: BoxDecoration(
      //   border: isBottomIndicator
      //       ? Border(
      //           bottom: BorderSide(
      //             color: Palette.appColor,
      //             width: 3.0,
      //           ),
      //         )
      //       : Border(
      //           top: BorderSide(
      //             color: Palette.appColor,
      //             width: 3.0,
      //           ),
      //         ),
      // ),
      tabs: icons
          .asMap()
          .map((i, e) => MapEntry(
                i,
                Tab(
                  iconMargin: EdgeInsets.zero,
                  icon: Icon(
                    e,
                    color: i == selectedIndex
                        ? Theme.of(context).primaryColor
                        : Colors.black45,
                    size: 30,
                  ),
                  // text: 'Home',
                  child: Text(
                    i == 0
                        ? 'Home'
                        : i == 1
                            ? 'Search'
                            : i == 2
                                ? 'Live'
                                : i == 3
                                    ? 'Chat'
                                    : 'Profile',
                    style: TextStyle(
                      color: i == selectedIndex
                          ? Theme.of(context).primaryColor
                          : Colors.black45,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  // icon: Obx(() {
                  //   return Icon(
                  //     liveStreamController
                  //                 .loadingAllowedStreamingChecker.value &&
                  //             i == 2
                  //         ? Icons.refresh_outlined
                  //         : e,
                  //     color: i == 2
                  //         ? Colors.redAccent
                  //         : i == selectedIndex
                  //             ? Theme.of(context).primaryColor
                  //             : Colors.black45,
                  //     size: i == 2 ? 46 : 30.0,
                  //   );
                  // }),
                ),
              ))
          .values
          .toList(),
      onTap: onTap,
    );
  }
}
