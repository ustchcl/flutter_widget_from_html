part of '../helpers.dart';

class VideoPlayer extends StatefulWidget {
  final String url;

  final double aspectRatio;
  final bool autoResize;
  final bool autoplay;
  final bool controls;
  final bool loop;
  final Widget poster;

  VideoPlayer(
    this.url, {
    @required this.aspectRatio,
    this.autoResize = true,
    this.autoplay = false,
    this.controls = false,
    Key key,
    this.loop = false,
    this.poster,
  })  : assert(url != null),
        assert(aspectRatio != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  _Controller _controller;

  @override
  void initState() {
    super.initState();
    _controller = _Controller(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => lib.Chewie(controller: _controller);

  void _onAspectRatioUpdated() => setState(() {});
}

class _Controller extends lib.ChewieController {
  final _VideoPlayerState vps;

  double _aspectRatio;

  _Controller(this.vps)
      : super(
          autoInitialize: true,
          autoPlay: vps.widget.autoplay == true,
          looping: vps.widget.loop == true,
          placeholder: vps.widget.poster != null
              ? Center(child: vps.widget.poster)
              : null,
          showControls: vps.widget.controls == true,
          videoPlayerController:
              lib.VideoPlayerController.network(vps.widget.url),
        ) {
    if (vps.widget.autoResize) {
      _setupAspectRatioListener();
    }
  }

  @override
  double get aspectRatio => _aspectRatio ?? vps.widget.aspectRatio;

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  void _setupAspectRatioListener() {
    VoidCallback listener;

    listener = () {
      if (_aspectRatio == null) {
        final vpv = videoPlayerController.value;
        debugPrint('[_Controller]: vpv=$vpv');

        if (!vpv.initialized) return;
        _aspectRatio = vpv.aspectRatio;

        // workaround because we cannot call `vps.setState()` directly
        vps._onAspectRatioUpdated();
      }

      videoPlayerController.removeListener(listener);
    };

    videoPlayerController.addListener(listener);
  }
}
