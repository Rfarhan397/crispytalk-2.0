import 'dart:developer';
import 'package:crispy/model/res/constant/app_assets.dart';
import 'package:crispy/model/res/widgets/cachedImage/cachedImage.dart';
import 'package:crispy/provider/action/action_provider.dart';
import 'package:crispy/screens/mainScreen/suggestedUser/suggestedUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../constant.dart';
import '../../model/mediaPost/mediaPost_model.dart';
import '../../model/res/components/app_back_button.dart';
import '../../model/res/components/app_button_widget.dart';
import '../../model/res/components/shimmer.dart';
import '../../model/res/constant/app_icons.dart';
import '../../model/res/routes/routes_name.dart';
import '../../model/res/widgets/app_text.dart.dart';
import '../../model/user_model/user_model.dart';
import '../../provider/postCache/postCacheProvider.dart';
import '../../provider/stream/streamProvider.dart';
import '../ImageDetail/image_detail.dart';
import '../myProfile/otherUserProfile/otherUserProfile.dart';
import '../sampleVideo/fullscreenSample.dart';
import '../sampleVideo/tiktokVIdeoPlayer.dart';
import '../video/videoScreen.dart';
import '../video/videoWidget.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<VideoWidgetState> videoKey = GlobalKey<VideoWidgetState>();

  @override
  void initState() {
    super.initState();
    // Initialize posts cache when home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PostCacheProvider>().initializePosts();
      }
    });
  }

  @override
  void dispose() {
    // Remove clearCache call from here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: AppTextWidget(
          text: 'Crispytalk',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: primaryColor,
          shadows: [
            Shadow(
              offset: const Offset(2.0, 2.0),
              blurRadius: 3.0,
              color: Colors.black.withOpacity(0.6),
            ),
          ],
        ),
        actions: [
          GestureDetector(
              onTap: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(
                      userStream: StreamDataProvider().getUsers()),
                );
              },
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: SvgPicture.asset(AppIcons.search))),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 21.h,
                color: Colors.transparent,
                child: StreamBuilder(
                  stream: StreamDataProvider().getPostsWithUserDetails(
                    audience: 'Everyone',
                    userStatus: 'true',
                    currentUserId: currentUser,
                    includeCurrentUser: false,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      final cachedData =
                          context.watch<PostCacheProvider>().cachedPosts;
                      if (cachedData != null) {
                        return buildPostsList(cachedData);
                      }
                      return ShimmerContainer();
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No posts available'));
                    }

                    final posts = snapshot.data ?? [];

                    posts.sort(
                        (a, b) => b.likes.length.compareTo(a.likes.length));

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final postData = posts[index];
                        final profileImage = postData.userDetails?.profileUrl;
                        final userName =
                            postData.userDetails?.name.capitalizeFirst ??
                                'Unknown User';
                        final mediaUrl = postData.mediaUrl ?? '';
                        final mediaType = postData.mediaType ?? '';

                        return Padding(
                          padding: EdgeInsets.only(right: 2.w),
                          child: buildPhotoCard(
                            profileImage: profileImage.toString(),
                            userName: userName,
                            mediaUrl: customLink + mediaUrl,
                            mediaType: mediaType,
                            onTap: () {
                              // Get.toNamed(
                              //   RoutesName.video,
                              //   arguments: {'videoUrl': mediaUrl},
                              // );
                              context.read<ActionProvider>().saveModel(posts);
                              Get.to(() => VideoFeedScreen(
                                    initialIndex: index,
                                  ));
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SuggestedUsers(
                  currentUserId: FirebaseAuth.instance.currentUser!.uid),
              SizedBox(
                height: 1.h,
              ),
              StreamBuilder(
                stream: StreamDataProvider().getPostsWithUserDetails(
                  audience: 'Everyone',
                  userStatus: 'true',
                  currentUserId: currentUser,
                  includeCurrentUser: false,
                ),
                builder: (context, snapshot) {
                  final posts = List<MediaPost>.from(snapshot.data ?? []);

                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.hasError) {
                    final cachedData =
                        context.watch<PostCacheProvider>().cachedPosts;
                    if (cachedData != null) {
                      return buildVerticalPostsList(posts);
                    }
                    return const PostShimmerWidget();
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    final cachedData =
                        context.watch<PostCacheProvider>().cachedPosts;
                    if (cachedData != null) {
                      return buildVerticalPostsList(posts);
                    }
                    return const Center(child: Text('No posts available'));
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      context.read<PostCacheProvider>().setCachedPosts(posts);
                    }
                  });

                  return buildVerticalPostsList(posts);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildVerticalPostsList(List<MediaPost> post) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: post.length,
      itemBuilder: (context, index) {
        final postData = post[index];
        return Padding(
          padding: EdgeInsets.only(right: 3.w),
          child: buildPostContainer(
            () {
              Get.to(OtherUserProfile(
                  userID: postData.userUid,
                  userName: postData.userDetails!.name));
            },
            postData.userDetails?.profileUrl ?? "",
            postData.userDetails?.name.capitalizeFirst ?? 'Unknown User',
            _formatTime(postData.timeStamp) ?? 'time',
            postData.title,
            () {
              final isImage = postData.mediaType == 'image';

              final isVideo = postData.mediaType == 'mp4';

              if (isVideo) {
                log('the video is already available ${customLink + postData.mediaUrl}');
                context.read<ActionProvider>().saveModel(post);
                Get.to(
                    VideoFeedScreen(
                  initialIndex: index,
                ),
                );




              }

              if (isImage) {
                Get.to(ImageDetailScreen(imageUrl: postData.mediaUrl));
              }
            },
            postData.mediaUrl,
            postData.likes,
            postData.mediaType,
          ),
        );
      },
    );
  }

  String _formatTime(String timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    final now = DateTime.now();

    if (now.difference(dateTime).inMinutes < 60) {
      return '${now.difference(dateTime).inMinutes} min ago';
    } else if (now.difference(dateTime).inHours < 24) {
      return '${now.difference(dateTime).inHours} hours ago';
    } else {
      return '${now.difference(dateTime).inDays} days ago';
    }
  }

  // Build photo card widget
  Widget buildPhotoCard({
    required String profileImage,
    required String userName,
    required VoidCallback onTap,
    required String mediaType,
    required String mediaUrl,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        width: 35.w,
        height: 25.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (mediaType == 'image')
              ClipRRect(
                child: CachedShimmerImageWidget(
                  width: double.infinity,
                  height: double.infinity,
                  imageUrl: mediaUrl,
                  fit: BoxFit.cover,
                ),
              )
            else if (mediaType == 'mp4')
              ClipRRect(
                child: SizedBox(
                  child: VideoWidget(
                    isFirst: true,
                    showPlayPauseButton: false,
                    isAutoPlay: false,
                    mediaUrl: mediaUrl,
                    onTogglePlayPause: () {
                      videoKey.currentState?.togglePlayPause();
                    },
                  ),
                ),
              )
            else
              const Center(
                child: Text(
                  'Unsupported media format',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            // Overlay for user profile and name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CachedShimmerImageWidget(
                            imageUrl: profileImage,
                          ),
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Flexible(
                        child: AppTextWidget(
                          text: userName,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPostContainer(
    VoidCallback profileOnTap,
    String profileImage,
    String userName,
    String time,
    String caption,
    VoidCallback onTap,
    String video,
    List<String> likes,
    String mediaType, // Add mediaType parameter
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: profileOnTap,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: profileImage.isNotEmpty
                        ? CachedShimmerImageWidget(
                            imageUrl: profileImage,
                          )
                        : Image.asset(AppAssets.noProfile),
                  ),
                ),
                SizedBox(width: 2.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextWidget(
                      text: userName,
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    AppTextWidget(
                      text: time,
                      color: customGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 0.5.h),
          AppTextWidget(
            text: caption,
            color: Colors.black,
            fontSize: 13,
          ),
          SizedBox(height: 1.h),
          Stack(
            children: [
              // Post Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GestureDetector(
                  onTap: onTap,
                  child: mediaType == 'image'
                      ? Image.network(
                          customLink + video,
                          width: double.infinity,
                          height: 30.h,
                          fit: BoxFit.cover,
                        )
                      : mediaType == 'mp4'
                          ? SizedBox(
                              // color: customGrey,
                              // height: 30.h,
                              width: double.infinity,
                              child: VideoWidget(
                                isAutoPlay: true,
                                showPlayPauseButton: true,
                                mediaUrl: customLink + video,
                                onTogglePlayPause: () {
                                  videoKey.currentState?.togglePlayPause();
                                },
                              ),
                            )
                          : const AppTextWidget(
                              text: 'Video Not Found',
                              color: Colors.black,
                            ), // Fallback for unknown types
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      likes.isNotEmpty ? AppIcons.like : AppIcons.notLike,
                      height: 15,
                    ),
                    SizedBox(width: 1.w),
                    AppTextWidget(
                      text: likes.length.toString(),
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    SizedBox(width: 3.w),
                    SvgPicture.asset(
                      AppIcons.message,
                      height: 15,
                    ),
                    SizedBox(width: 1.w),
                    const AppTextWidget(
                      text: 'comments',
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
        ],
      ),
    );
  }

  Widget buildSuggestion(profileImage, username, email) {
    return Container(
      width: 25.w,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: primaryColor,
            child: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(profileImage),
            ),
          ),
          SizedBox(height: 0.5.h),
          AppTextWidget(
            text: username,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),

          AppTextWidget(
            text: email,
            fontSize: 11,
            color: const Color(0xff6F6D6D),
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1.h),
          // Follow button
          AppButtonWidget(
              width: 20.w,
              alignment: Alignment.center,
              height: 3.h,
              radius: 100,
              onPressed: () {},
              fontSize: 13,
              fontWeight: FontWeight.w500,
              text: 'Follow')
        ],
      ),
    );
  }

  Widget buildPostsList(List<MediaPost> posts) {
    posts.sort((a, b) => b.likes.length.compareTo(a.likes.length));

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final postData = posts[index];
        final profileImage = postData.userDetails?.profileUrl;
        final userName =
            postData.userDetails?.name.capitalizeFirst ?? 'Unknown User';
        final mediaUrl = postData.mediaUrl ?? '';
        final mediaType = postData.mediaType ?? '';

        return Padding(
          padding: EdgeInsets.only(right: 2.w),
          child: buildPhotoCard(
            profileImage: profileImage.toString(),
            userName: userName,
            mediaUrl: mediaUrl,
            mediaType: mediaType,
            onTap: () {
              Get.toNamed(
                RoutesName.video,
                arguments: {'videoUrl': mediaUrl},
              );
            },
          ),
        );
      },
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final Stream<List<UserModelT>> userStream;

  CustomSearchDelegate({required this.userStream});

  @override
  String get searchFieldLabel => 'Search';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      GestureDetector(
          onTap: () {
            query = "";
          },
          child: Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: SvgPicture.asset(AppIcons.close),
          )),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return const AppBackButton();
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildUserStream();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildUserStream();
  }

  Widget _buildUserStream() {
    return StreamBuilder<List<UserModelT>>(
      stream: userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error fetching users"));
        }

        final users = snapshot.data ?? [];
        final filteredUsers = users.where((user) {
          return user.name.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase());
        }).toList();

        if (filteredUsers.isEmpty) {
          return const Center(child: Text("No users found"));
        }

        return ListView.builder(
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index];

            return ListTile(
              onTap: () {
                Get.to(
                  OtherUserProfile(userID: user.userUid, userName: user.name),
                );
              },
              leading: CircleAvatar(
                radius: 25,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedShimmerImageWidget(imageUrl: user.profileUrl)),
              ),
              title: Text(user.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(user.email),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            );
          },
        );
      },
    );
  }
}
