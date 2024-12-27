import 'package:crispy/constant.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String userName;
  final String profileImage;

  const FullScreenVideoPlayer({
    Key? key,
    required this.videoUrl,
    required this.userName,
    required this.profileImage,
  }) : super(key: key);

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      _isPlaying ? _controller.play() : _controller.pause();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Player
          GestureDetector(
            onTap: _togglePlayPause,
            child: Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
                  : const CircularProgressIndicator(),
            ),
          ),

          // User Info Overlay
          Positioned(
            top: 40,
            left: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.profileImage),
                  radius: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Play/Pause Icon Overlay
          if (!_isPlaying)
            Center(
              child: Icon(
                Icons.play_arrow,
                size: 80,
                color: Colors.white.withOpacity(0.8),
              ),
            ),

          // Video Progress Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: primaryColor,
                bufferedColor: Colors.grey,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}