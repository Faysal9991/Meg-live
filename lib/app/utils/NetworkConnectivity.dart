import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkConnectivity {
  NetworkConnectivity._();
  static final _instance = NetworkConnectivity._();
  static NetworkConnectivity get instance => _instance;
  final _networkConnectivity = Connectivity();
  final _controller = StreamController.broadcast();
  Stream get myStream => _controller.stream;

  void initialise() async {
    // ConnectivityResult result = await _networkConnectivity.checkConnectivity();
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    _checkStatus(connectivityResult);
    _networkConnectivity.onConnectivityChanged.listen((result) {
      // E.g. ConnectivityResult.wifi
      _checkStatus(connectivityResult);
    });
  }

  void _checkStatus(List<ConnectivityResult> connectivityResult) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('doyellive.mmpvtltd.xyz');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      isOnline = false;
    }
    if (!_controller.isClosed && !_controller.isPaused) {
      _controller.sink.add({connectivityResult: isOnline});
    }
  }

//   void initialise() async {
//     ConnectivityResult result = await _networkConnectivity.checkConnectivity();
//     _checkStatus(result);
//     _networkConnectivity.onConnectivityChanged.listen((result) {
//       // E.g. ConnectivityResult.wifi
//       _checkStatus(result);
//     });
//   }

//   void _checkStatus(ConnectivityResult result) async {
//     bool isOnline = false;
//     try {
//       final result = await InternetAddress.lookup('doyellive.mmpvtltd.xyz');
//       isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } on SocketException catch (_) {
//       isOnline = false;
//     }
//     if (!_controller.isClosed && !_controller.isPaused) {
//       _controller.sink.add({result: isOnline});
//     }
//   }

  void disposeStream() => _controller.close();
}



// doyellive.mmpvtltd.xyz