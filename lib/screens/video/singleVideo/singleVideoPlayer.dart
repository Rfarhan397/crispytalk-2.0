// lib/screens/single_video_player_screen.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../constant.dart';
import '../../../model/mediaPost/mediaPost_model.dart';
import '../../../model/res/components/commentBottomSheet.dart';
import '../../../provider/action/action_provider.dart';
import '../../../provider/current_user/current_user_provider.dart';
import '../../myProfile/otherUserProfile/otherUserProfile.dart';
import 'components/singleVideoControls.dart';
import 'components/singleVideoOverlay.dart';
import 'components/videoPlayerManager.dart';

class SingleVideoPlayerScreen extends StatefulWidget {
  final MediaPost media;

  const SingleVideoPlayerScreen({
    Key? key,
    required this.media,
  }) : super(key: key);

  @override
  State<SingleVideoPlayerScreen> createState() => _SingleVideoPlayerScreenState();
}

class _SingleVideoPlayerScreenState extends State<SingleVideoPlayerScreen> {
  late VideoPlayerManager _videoManager;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoManager = VideoPlayerManager(
        videoUrl: customLink + widget.media.mediaUrl,
      );
      await _videoManager.initialize();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoManager.dispose();
    super.dispose();
  }

  void _handleComment() {
    final userDetails = widget.media.userDetails!;


    Get.bottomSheet(
      CommentBottomSheet(
        postId: widget.media.timeStamp,
        token: userDetails.fcmToken,
        postOwnerUid: widget.media.userUid,
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text(_error!, style: TextStyle(color: Colors.white))),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: _videoManager.togglePlay,
            child: Center(
              child: AspectRatio(
                aspectRatio: _videoManager.controller.value.aspectRatio,
                child: VideoPlayer(_videoManager.controller),
              ),
            ),
          ),

          VideoControls(
            controller: _videoManager.controller,
            isPlaying: _videoManager.isPlaying,
            onPlayPause: _videoManager.togglePlay,
          ),

          VideoInfoOverlay(
            media: widget.media,
            onComment: () {
              _handleComment();
            },
            onLike: () {
              _handleLike();
            },
            onProfileTap: () {
              _handleProfileTap();
            },
            onSave: () {
              log('onSave');
              _handleSave();
            },
            onShare: () {
              _handleShare();
            },
          ),

          const SafeArea(
            child: BackButton(color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _handleLike() {
    if (widget.media.userDetails?.fcmToken != null) {
      Provider.of<ActionProvider>(context, listen: false)
          .toggleLike(widget.media.timeStamp, widget.media.likes);
    }
  }

  void _handleProfileTap() {
    log('profile tap');
    final userDetails = widget.media.userDetails;
    if (userDetails?.userUid != null) {
      log('profile tap');

      Get.to(
        OtherUserProfile(
          userID: userDetails!.userUid,
          userName: userDetails.name ?? 'Unknown',
        ),
      );
    }
  }

  void _handleSave() {
    log('profile save');

    Provider.of<ActionProvider>(context, listen: false)
        .toggleSave(widget.media.timeStamp, widget.media.saves);
  }

  void _handleShare() {
    shareVideo(widget.media.mediaUrl);
  }
}
