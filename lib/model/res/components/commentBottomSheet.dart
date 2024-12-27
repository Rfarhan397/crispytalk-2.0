import 'package:crispy/model/res/components/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import '../../../constant.dart';
import '../../../provider/action/action_provider.dart';
import '../../../provider/current_user/current_user_provider.dart';
import '../../../provider/stream/streamProvider.dart';
import '../constant/app_icons.dart';
import '../widgets/app_text.dart.dart';
import '../widgets/cachedImage/cachedImage.dart';
import '../widgets/customDialog.dart';

class CommentBottomSheet extends StatelessWidget {
  final String postId, token, postOwnerUid;
   CommentBottomSheet({
     super.key,
    required this.postId,
    required this.token,
    required this.postOwnerUid,
   });

  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final action = Provider.of<ActionProvider>(context, listen: false);
    final currentUserProvider = Provider.of<CurrentUserProvider>(context, listen: false).currentUser;
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AppTextWidget(
                text: 'Comments',
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder(
                  stream:
                  StreamDataProvider().getCommentsWithUserDetails(postId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CommentShimmerWidget();
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text(
                          "No Comments on this post yet",
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    final comments = snapshot.data ?? [];
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: GestureDetector(
                            onLongPress: () {
                              final currentUserId =
                                  currentUserProvider?.userUid;

                              if (comment.user.userUid == currentUserId ||
                                  postOwnerUid == currentUserId) {
                                MyCustomDialog.show(
                                  title: "Delete Comment",
                                  content:
                                  "Are you sure you want to delete this comment?",
                                  cancel: "Cancel",
                                  yes: "Delete",
                                  showTextField: false,
                                  showTitle: true,
                                  cancelTap: () {
                                    Navigator.pop(context);
                                  },
                                  yesTap: () async {
                                    await action.removeComment(
                                        postId, comment.comment.commentId);
                                    Navigator.pop(context);
                                  },
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  // border: Border.all(
                                  //   color: primaryColor,
                                  // ),
                                  color: customGrey.withOpacity(0.8)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey[500],
                                    child: ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(100),
                                        child: CachedShimmerImageWidget(
                                            imageUrl: comment.user.profileUrl)),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            AppTextWidget(
                                              textAlign: TextAlign.start,
                                              text: comment.user.name,
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            AppTextWidget(
                                              textAlign: TextAlign.start,
                                              text: getTimeAgo(comment.comment
                                                  .timestamp), // Pass the string timestamp here
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        AppTextWidget(
                                          textAlign: TextAlign.start,
                                          text: comment.comment.content,
                                          overflow: TextOverflow.visible,
                                          maxLines: null,
                                          softWrap: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle:
                        const TextStyle(fontSize: 14, color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: const BorderSide(
                            style: BorderStyle.solid,
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () async {
                              if (commentController.text.isNotEmpty) {
                                await Provider.of<ActionProvider>(context,
                                    listen: false)
                                    .addComment(
                                    postId,
                                    commentController.text,
                                    token,
                                    currentUserProvider!.name.toString(),
                                    postOwnerUid,
                                    'commented on your video');
                                commentController.clear();
                              }
                            },
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SvgPicture.asset(
                                  AppIcons.share,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
  String getTimeAgo(String timestampString) {
    // Parse the string to an integer
    int timestampMillis = int.parse(timestampString);

    // Convert to DateTime
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestampMillis);
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} s';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} h';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} d';
    } else {
      return DateFormat('MMM dd, yyyy')
          .format(dateTime); // Return formatted date for older timestamps
    }
  }

  // Share function to handle sharing the video URL
  void shareVideo(String mediaUrl) {
    if (mediaUrl.isNotEmpty) {
      Share.share(mediaUrl, subject: "Check out this video!");
    }
  }

  Widget BuildShareBottomSheet(profileImage, profileName) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppTextWidget(
              text: 'Share Video', fontSize: 15, fontWeight: FontWeight.w500),
          const SizedBox(height: 10),
          SizedBox(
              height: 100,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 10,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                height: 54,
                                width: 54,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.asset(
                                    profileImage,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 1.h),
                                child: AppTextWidget(
                                    text: profileName,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  })),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
