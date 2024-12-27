// lib/controllers/video_player_controller.dart
import 'package:video_player/video_player.dart';

class VideoPlayerManager {
  late VideoPlayerController controller;
  bool isPlaying = false;
  final String videoUrl;

  VideoPlayerManager({required this.videoUrl});

  Future<void> initialize() async {
    try {
      controller = VideoPlayerController.network(videoUrl);
      await controller.initialize();
      controller.setLooping(true);
      controller.play();
      isPlaying = true;
    } catch (e) {
      throw VideoPlayerException('Failed to initialize video: $e');
    }
  }

  void togglePlay() {
    if (!controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  void dispose() {
    controller.dispose();
  }
}

class VideoPlayerException implements Exception {
  final String message;
  VideoPlayerException(this.message);
}
