import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:doyel_live/app/modules/profile/controllers/profile_controller.dart';

class BroadcastingHistoriesView extends GetView {
  BroadcastingHistoriesView({
    required this.userId,
    required this.isAgentSearch,
    super.key,
  });
  final int userId;
  final bool isAgentSearch;
  final ProfileController _profileController = Get.find();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Histories'), centerTitle: true),
        body: FutureBuilder(
          future: _profileController.fecthBroadcastingHistories(),
          builder: (context, snapshot) {
            // Checking if future is resolved
            if (snapshot.connectionState == ConnectionState.done) {
              // If we got an error
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Error occurred',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                );

                // if we got our data
              } else if (snapshot.hasData) {
                // Extracting data from snapshot object
                final dataList = snapshot.data as List<dynamic>;
                if (dataList.isEmpty) {
                  return const Center(
                    child: Text(
                      'No history',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: ListView.separated(
                    // padding: EdgeInsets.zero,
                    itemCount: dataList.length,
                    itemBuilder: (context, index) {
                      dynamic data = dataList[index];
                      return HistoryItem(data: data);
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 1);
                    },
                  ),
                );
              }
            }
            return Center(
              child: SpinKitHourGlass(
                color: Theme.of(context).primaryColor,
                size: 50.0,
              ),
            );
          },
        ),
      ),
    );
  }
}

class HistoryItem extends StatelessWidget {
  const HistoryItem({Key? key, this.data}) : super(key: key);
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // colors: [
            //   Colors.orange.withOpacity(.5),
            //   Theme.of(context).primaryColor.withOpacity(.5),
            //   Colors.black38,
            // ],
            colors: [Colors.blue, Theme.of(context).primaryColor],

            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Date: ${data['broadcasting_date']}',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w900,
              ),
            ),
            // Text(
            //   'Audio: ${(data['audio_broadcast_in_second'] / 60).toStringAsFixed(2)} minutes',
            //   style: const TextStyle(
            //     color: Colors.white70,
            //     fontWeight: FontWeight.w900,
            //   ),
            // ),
            Text(
              // 'Video: ${(data['video_broadcast_in_second'] / 60).toStringAsFixed(2)} minutes',
              '(H:M:S): ${_printDuration(Duration(seconds: data['video_broadcast_in_second']))}',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _printDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}
