import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoControls extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isPlaying;
  final VoidCallback onPlayPause;

  const VideoControls({
    Key? key,
    required this.controller,
    required this.isPlaying,
    required this.onPlayPause,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: AnimatedOpacity(
        opacity: isPlaying ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              size: 50,
              color: Colors.white,
            ),
            onPressed: onPlayPause,
          ),
        ),
      ),
    );
  }
}