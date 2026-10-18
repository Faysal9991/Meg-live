import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';

class NetworkConnectivity {
  NetworkConnectivity._();
  static final _instance = NetworkConnectivity._();
  static NetworkConnectivity get instance => _instance;
  final _networkConnectivity = Connectivity();
  final _controller = StreamController.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _changes;
  Stream get myStream => _controller.stream;

  /// Checks now and on every network change. Safe to call again on resume:
  /// the change listener is registered only once.
  void initialise() async {
    _changes ??= _networkConnectivity.onConnectivityChanged.listen(
      // Check the network we switched to (e.g. Wi-Fi -> mobile data), not the
      // one the app started on.
      _checkStatus,
    );
    _checkStatus(await _networkConnectivity.checkConnectivity());
  }

  void _checkStatus(List<ConnectivityResult> connectivityResult) async {
    bool isOnline = false;
    if (!connectivityResult.every((r) => r == ConnectivityResult.none)) {
      // Mobile data can take a moment to route after a switch; retry before
      // declaring the app offline.
      for (var attempt = 0; attempt < 3 && !isOnline; attempt++) {
        if (attempt > 0) await Future.delayed(const Duration(seconds: 2));
        try {
          final result = await InternetAddress.lookup(
            Uri.parse(kDomain).host,
          ).timeout(const Duration(seconds: 5));
          isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        } catch (_) {
          isOnline = false;
        }
      }
    }
    if (!_controller.isClosed && !_controller.isPaused) {
      _controller.sink.add({connectivityResult: isOnline});
    }
  }

  void disposeStream() {
    _changes?.cancel();
    _changes = null;
    _controller.close();
  }
}
