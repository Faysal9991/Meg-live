import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svga/flutter_svga.dart';
import 'package:video_player/video_player.dart';

enum AnimatedMediaType { image, video, svga, unsupported }

/// Normalizes the media fields returned by gift and entry-effect APIs.
///
/// Some older API responses put MP4 or SVGA URLs in the `gif` field, so the
/// file extension is treated as the source of truth instead of the field name.
class AnimatedMediaSource {
  const AnimatedMediaSource({required this.url, required this.type});

  final String? url;
  final AnimatedMediaType type;

  bool get isPlayable => url != null && type != AnimatedMediaType.unsupported;

  factory AnimatedMediaSource.fromUrls({
    dynamic svga,
    dynamic gif,
    dynamic image,
  }) {
    final candidates = <String?>[
      _normalizeUrl(svga),
      _normalizeUrl(gif),
      _normalizeUrl(image),
    ];

    String? unsupportedCandidate;
    for (final candidate in candidates) {
      if (candidate != null) {
        final type = typeOf(candidate);
        if (type != AnimatedMediaType.unsupported) {
          return AnimatedMediaSource(url: candidate, type: type);
        }
        unsupportedCandidate ??= candidate;
      }
    }
    return AnimatedMediaSource(
      url: unsupportedCandidate,
      type: AnimatedMediaType.unsupported,
    );
  }

  factory AnimatedMediaSource.fromMap(
    Map<dynamic, dynamic> data, {
    bool includeGiftImage = true,
  }) {
    return AnimatedMediaSource.fromUrls(
      svga: data['svga'],
      gif: data['gif'],
      image: includeGiftImage ? data['gift_image'] ?? data['image'] : null,
    );
  }

  static AnimatedMediaType typeOf(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    if (path.endsWith('.svga')) return AnimatedMediaType.svga;
    if (path.endsWith('.mp4') ||
        path.endsWith('.mov') ||
        path.endsWith('.m4v') ||
        path.endsWith('.webm') ||
        path.endsWith('.m3u8')) {
      return AnimatedMediaType.video;
    }
    if (path.endsWith('.gif') ||
        path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp')) {
      return AnimatedMediaType.image;
    }
    return AnimatedMediaType.unsupported;
  }

  static String? _normalizeUrl(dynamic value) {
    var text = value?.toString().trim() ?? '';
    if (text.isEmpty || text.toLowerCase() == 'null') return null;

    final markdown = RegExp(r'^\[[^\]]*\]\(([^)]+)\)$').firstMatch(text);
    text = (markdown?.group(1) ?? text).replaceAll(r'\', '').trim();
    final uri = Uri.tryParse(text);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    return text;
  }
}

/// Reusable player for animated gifts and room-entry effects.
class AnimatedMediaWidget extends StatelessWidget {
  const AnimatedMediaWidget({
    super.key,
    required this.source,
    this.fit = BoxFit.contain,
    this.loop = true,
    this.autoPlay = true,
    this.placeholder,
    this.errorWidget,
  });

  final AnimatedMediaSource source;
  final BoxFit fit;
  final bool loop;
  final bool autoPlay;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final url = source.url;
    if (url == null) return errorWidget ?? _defaultError();

    switch (source.type) {
      case AnimatedMediaType.image:
        return CachedNetworkImage(
          key: ValueKey<String>('image:$url'),
          imageUrl: url,
          fit: fit,
          placeholder: (_, __) => placeholder ?? _defaultLoader(),
          errorWidget: (_, __, ___) => errorWidget ?? _defaultError(),
        );
      case AnimatedMediaType.video:
        return _NetworkVideo(
          key: ValueKey<String>('video:$url'),
          url: url,
          fit: fit,
          loop: loop,
          autoPlay: autoPlay,
          placeholder: placeholder,
          errorWidget: errorWidget,
        );
      case AnimatedMediaType.svga:
        return _NetworkSvga(
          key: ValueKey<String>('svga:$url'),
          url: url,
          fit: fit,
          loop: loop,
          autoPlay: autoPlay,
          placeholder: placeholder,
          errorWidget: errorWidget,
        );
      case AnimatedMediaType.unsupported:
        return errorWidget ?? _defaultError();
    }
  }

  static Widget _defaultLoader() => const Center(
    child: SizedBox.square(
      dimension: 28,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );

  static Widget _defaultError() =>
      const Center(child: Icon(Icons.auto_awesome_motion_outlined, size: 42));
}

class _NetworkVideo extends StatefulWidget {
  const _NetworkVideo({
    super.key,
    required this.url,
    required this.fit,
    required this.loop,
    required this.autoPlay,
    this.placeholder,
    this.errorWidget,
  });

  final String url;
  final BoxFit fit;
  final bool loop;
  final bool autoPlay;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  State<_NetworkVideo> createState() => _NetworkVideoState();
}

class _NetworkVideoState extends State<_NetworkVideo> {
  VideoPlayerController? _controller;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller = controller;
    try {
      await controller.initialize();
      if (!mounted || _controller != controller) return;
      await controller.setLooping(widget.loop);
      await controller.setVolume(0);
      if (widget.autoPlay) await controller.play();
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted && _controller == controller) {
        setState(() => _error = error);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_error != null) {
      return widget.errorWidget ?? AnimatedMediaWidget._defaultError();
    }
    if (controller == null || !controller.value.isInitialized) {
      return widget.placeholder ?? AnimatedMediaWidget._defaultLoader();
    }

    final size = controller.value.size;
    return FittedBox(
      fit: widget.fit,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}

class _NetworkSvga extends StatefulWidget {
  const _NetworkSvga({
    super.key,
    required this.url,
    required this.fit,
    required this.loop,
    required this.autoPlay,
    this.placeholder,
    this.errorWidget,
  });

  final String url;
  final BoxFit fit;
  final bool loop;
  final bool autoPlay;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  State<_NetworkSvga> createState() => _NetworkSvgaState();
}

class _NetworkSvgaState extends State<_NetworkSvga>
    with SingleTickerProviderStateMixin {
  late final SVGAAnimationController _controller;
  Object? _error;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = SVGAAnimationController(vsync: this);
    _load();
  }

  Future<void> _load() async {
    try {
      final movie = await SVGAParser.shared.decodeFromURL(widget.url);
      if (!mounted) {
        movie.dispose();
        return;
      }
      _controller.videoItem = movie;
      setState(() => _ready = true);
      if (widget.autoPlay) {
        if (widget.loop) {
          _controller.repeat(min: 0, max: 1, period: _controller.duration);
        } else {
          _controller.forward(from: 0);
        }
      }
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorWidget ?? AnimatedMediaWidget._defaultError();
    }
    if (!_ready) {
      return widget.placeholder ?? AnimatedMediaWidget._defaultLoader();
    }
    return SVGAImage(
      _controller,
      fit: widget.fit,
      clearsAfterStop: false,
      allowDrawingOverflow: false,
    );
  }
}
