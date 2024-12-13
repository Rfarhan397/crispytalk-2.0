import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../constant.dart';

class VideoWidget extends StatefulWidget {
  final String mediaUrl;
  final bool isAutoPlay;
  final bool isFirst;
  final bool showPlayPauseButton;
  final VoidCallback? onTogglePlayPause;

  const VideoWidget({
    super.key,
    required this.mediaUrl,
    required this.isAutoPlay,
    this.showPlayPauseButton = true,
    this.onTogglePlayPause,this.isFirst = false,
  });

  @override
  VideoWidgetState createState() => VideoWidgetState();
}

class VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoController();
  }

  void _initializeVideoController() {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.mediaUrl),
      videoPlayerOptions:  VideoPlayerOptions(
        mixWithOthers: false,
        allowBackgroundPlayback: false,
      ),
    )
      ..initialize().then((_) {
        setState(() {});
        if (widget.isAutoPlay) {
          _controller.play();
          _isPlaying = true;
        }
      }).catchError((error) {
        debugPrint("Error initializing video: $error");
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = !_isPlaying;
      if (widget.onTogglePlayPause != null) {
        widget.onTogglePlayPause!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.isFirst?Stack(
      alignment: Alignment.center,
      children: [
        if (_controller.value.isInitialized)
        // Use a Container to define the size
          Container(
            width: double.infinity,  // Define the width of the container
            height: double.infinity, // Define the height of the container
            child: FittedBox(
              fit: BoxFit.cover, // Ensure the video fits and fills the container
              child: SizedBox(
                width: _controller.value.size?.width ?? 0,  // Ensure proper sizing
                height: _controller.value.size?.height ?? 0, // Ensure proper sizing
                child: VideoPlayer(_controller),
              ),
            ),
          )
        else
          Center(
            child: CircularProgressIndicator(color: primaryColor),
          ),
        // Conditionally show the play/pause button
        if (widget.showPlayPauseButton && _controller.value.isInitialized)
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: Colors.white,
              size: 64,
            ),
            onPressed: togglePlayPause,
          ),
      ],
    ): Stack(
      alignment: Alignment.center,
      children: [
        if (_controller.value.isInitialized)
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        else
          Center(
            child: CircularProgressIndicator(color: primaryColor),
          ),
        // Conditionally show the play/pause button
        if (widget.showPlayPauseButton && _controller.value.isInitialized)
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: Colors.white,
              size: 64,
            ),
            onPressed: togglePlayPause,
          ),
      ],
    );
  }
}
