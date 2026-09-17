import 'package:flutter/material.dart';

/// Keeps the room route mounted while the existing app underneath is usable.
class LiveRoomSession extends ChangeNotifier {
  Route<void>? _route;
  bool _minimized = false;

  bool get isActive => _route != null;
  bool get isMinimized => _minimized;

  void open(
    BuildContext context,
    WidgetBuilder builder, {
    bool replace = false,
  }) {
    if (restoreIfActive()) return;
    final room = Builder(builder: builder);
    final route = _LiveRoomRoute(
      session: this,
      pageBuilder: (_, __, ___) => ListenableBuilder(
        listenable: this,
        child: room,
        builder: (_, child) => IgnorePointer(
          ignoring: _minimized,
          child: ExcludeSemantics(
            excluding: _minimized,
            child: Opacity(opacity: _minimized ? 0 : 1, child: child),
          ),
        ),
      ),
    );
    _route = route;
    final navigator = Navigator.of(context);
    final result = replace
        ? navigator.pushReplacement<void, void>(route)
        : navigator.push<void>(route);
    result.whenComplete(() => detach(route));
  }

  void minimize() {
    if (_route == null || _minimized) return;
    _minimized = true;
    notifyListeners();
  }

  bool restoreIfActive() {
    final route = _route;
    if (route == null) return false;
    route.navigator?.popUntil((candidate) => candidate == route);
    _minimized = false;
    notifyListeners();
    return true;
  }

  void detach(Route<dynamic>? route) {
    if (_route != route || _route == null) return;
    _route = null;
    _minimized = false;
    // Route disposal can run during a build; update the floating control later.
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }
}

class MinimizedLiveOverlay extends StatelessWidget {
  const MinimizedLiveOverlay({
    super.key,
    required this.session,
    required this.child,
  });

  final LiveRoomSession session;
  final Widget child;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: session,
    child: child,
    builder: (context, child) => Stack(
      children: [
        child!,
        if (session.isMinimized)
          Positioned(
            right: 12,
            bottom: MediaQuery.paddingOf(context).bottom + 88,
            child: Material(
              elevation: 8,
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: session.restoreIfActive,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.open_in_full,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Return to live',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _LiveRoomRoute extends PageRouteBuilder<void> {
  _LiveRoomRoute({required this.session, required super.pageBuilder})
    : super(
        settings: const RouteSettings(name: '/active-live-room'),
        opaque: false,
        maintainState: true,
      );

  final LiveRoomSession session;

  @override
  Widget buildModalBarrier() => ListenableBuilder(
    listenable: session,
    child: super.buildModalBarrier(),
    builder: (_, child) => IgnorePointer(
      ignoring: session.isMinimized,
      child: ExcludeSemantics(excluding: session.isMinimized, child: child!),
    ),
  );
}
