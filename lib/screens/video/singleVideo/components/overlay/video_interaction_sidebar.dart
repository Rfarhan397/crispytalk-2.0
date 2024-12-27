import 'package:crispy/model/res/constant/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';

import '../../../../../constant.dart';
import '../../../../../model/mediaPost/mediaPost_model.dart';
import '../../../../../model/res/constant/app_icons.dart';
import '../../../../../model/res/widgets/cachedImage/cachedImage.dart';
import '../../../../../provider/action/action_provider.dart';
import 'Interaction_button.dart';

class VideoInteractionSidebar extends StatelessWidget {
  final MediaPost media;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const VideoInteractionSidebar({
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
    return Positioned(
      right: 2.w,
      bottom: 10.h,
      child: Column(
        children: [
          // Profile Picture
          _buildProfilePicture(),
          SizedBox(height: 2.h),

          // Interaction Buttons
          InteractionButton(
            icon: media.likes.contains(currentUser)
                ? AppIcons.like
                : AppIcons.notLike,
            label: media.likes.length.toString(),
            onTap: onLike,
          ),
          SizedBox(height: 2.h),

          InteractionButton(
            icon: AppIcons.message,
            onTap: onComment,
          ),
          SizedBox(height: 2.h),

          InteractionButton(
            icon: AppIcons.share,
            onTap: onShare,
          ),
          SizedBox(height: 2.h),

          InteractionButton(
              icon: media.saves.contains(currentUser)
                  ? AppIcons.saveP
                  : AppIcons.save,
              label: 'Favourite',
              onTap: onSave),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    return GestureDetector(
      onTap: onProfileTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: CachedShimmerImageWidget(
            imageUrl: media.userDetails?.profileUrl ?? '',
          ),
        ),
      ),
    );
  }
}
