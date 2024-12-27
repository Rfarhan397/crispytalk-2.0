// lib/widgets/video/overlay/video_info_overlay.dart

import 'package:crispy/main.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../model/mediaPost/mediaPost_model.dart';
import 'overlay/video_interaction_sidebar.dart';

class VideoInfoOverlay extends StatelessWidget {
  final MediaPost media;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const VideoInfoOverlay({
    Key? key,
    required this.media,
    this.onProfileTap,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Caption overlay at the bottom
        Positioned(
          left: 0,
          right: 56, // Make space for interaction buttons
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  media.title ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        // Interaction sidebar on the right
        Positioned(
          right: 2.w,
          bottom: 10.h,
          child: VideoInteractionSidebar(
            media: media,
            onProfileTap: onProfileTap,
            onLike: onLike,
            onComment: onComment,
            onShare: onShare,
            onSave: onSave,
          ),
        ),
      ],
    );
  }
}
