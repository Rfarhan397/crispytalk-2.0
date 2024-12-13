import 'dart:developer';

import 'package:crispy/model/res/widgets/cachedImage/cachedImage.dart';
import 'package:crispy/screens/mainScreen/suggestedUser/suggestedUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import '../../constant.dart';
import '../../model/mediaPost/mediaPost_model.dart';
import '../../model/res/components/app_back_button.dart';
import '../../model/res/components/app_button_widget.dart';
import '../../model/res/components/shimmer.dart';
import '../../model/res/constant/app_assets.dart';
import '../../model/res/constant/app_icons.dart';
import '../../model/res/constant/app_utils.dart';
import '../../model/res/routes/routes_name.dart';
import '../../model/res/widgets/app_text.dart.dart';
import '../../provider/action/action_provider.dart';
import '../../provider/otherUserData/otherUserDataProvider.dart';
import '../../provider/stream/streamProvider.dart';
import '../../provider/user_provider/user_provider.dart';
import '../ImageDetail/image_detail.dart';
import '../myProfile/otherUserProfile/otherUserProfile.dart';
import '../video/mediaViewerScreen.dart';
import '../video/videoScreen.dart';
import '../video/videoWidget.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final GlobalKey<VideoWidgetState> videoKey =
      GlobalKey<VideoWidgetState>(); // Specify type here

  @override
  Widget build(BuildContext context) {
    log('build 2');
    final otherUser =
        Provider.of<OtherUSerDataProvider>(context); // Access provider

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
                  delegate: CustomSearchDelegate(),
                );
              },
              child: SvgPicture.asset(AppIcons.search)),

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
                            postData.userDetails?.name ?? 'Unknown User';
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return PostShimmerWidget();
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No posts available'));
                  }
                  final post = snapshot.data ?? [];
                  log('post data is $post');

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: post.length,
                    itemBuilder: (context, index) {
                      final postData = post[index];
                      String mediaType = '';
                      if (postData.mediaUrl.endsWith('.jpg') ||
                          postData.mediaUrl.endsWith('.jpeg')) {
                        mediaType = 'jpg';
                      } else if (postData.mediaUrl.endsWith('.png')) {
                        mediaType = 'png';
                      } else if (postData.mediaUrl.endsWith('.mov') ||
                          postData.mediaUrl.endsWith('.avi') ||
                          postData.mediaUrl.endsWith('.mp4')) {
                        mediaType = 'video';
                      }
                      final isLiked = postData.likes.contains(currentUser);

                      return Padding(
                        padding: EdgeInsets.only(right: 3.w),
                        child: buildPostContainer(
                          () {
                            Get.to(OtherUserProfile(userID: postData.userUid,userName: postData.userDetails!.name));
                          },
                          postData.userDetails?.profileUrl ?? "",
                          postData.userDetails?.name ?? 'Unknown User',
                          postData.title,
                          () {
                            final isImage =
                                postData.mediaUrl.endsWith('.jpg') ||
                                    postData.mediaUrl.endsWith('.png') ||
                                    postData.mediaUrl.endsWith('.jpeg');
                            final isVideo =
                                postData.mediaUrl.endsWith('.mp4') ||
                                    postData.mediaUrl.endsWith('.mov') ||
                                    postData.mediaUrl.endsWith('.avi');
                            if (isVideo) {
                              Get.to(VideoScreen(
                                index: index,
                                imagePath: postData.userDetails!.profileUrl,
                                hasBackBtn: true,
                              ));
                            }
                            if (isImage) {
                              Get.to(ImageDetailScreen(
                                  imageUrl: postData.mediaUrl));
                            }
                          },
                          postData.mediaUrl,
                          postData.likes,
                          postData.mediaType,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
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
            if (mediaType == 'jpg' || mediaType == 'png' || mediaType == 'jpeg')
              ClipRRect(
                child: CachedShimmerImageWidget(
                  width: double.infinity,
                  height: double
                      .infinity,
                  imageUrl:  mediaUrl,
                  fit: BoxFit.cover,
                // Make the image fill the entire container
                ),
              )
            else if (mediaType == 'mp4' ||
                mediaType == 'mov' ||
                mediaType == 'avi')
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
                      // CircleAvatar(
                      //   radius: 20,
                      //   backgroundImage: profileImage.isNotEmpty
                      //       ? NetworkImage(profileImage)
                      //       : const AssetImage(AppAssets.noProfile),
                      // ),
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
                   child: CachedShimmerImageWidget(
                     imageUrl: profileImage,
                   ),
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
                  child: mediaType == 'jpg' ||
                          mediaType == 'png' ||
                          mediaType == 'jpeg'
                      ? Image.network(
                          video,
                          width: double.infinity,
                          height: 30.h,
                          fit: BoxFit.cover,
                        )
                      : mediaType == 'mov' ||
                              mediaType == 'avi' ||
                              mediaType == 'mp4'
                          ? Container(
                              // color: customGrey,
                              // height: 30.h,
                              width: double.infinity,
                              child: VideoWidget(
                                isAutoPlay: false,
                                mediaUrl: video,
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


}

class CustomSearchDelegate extends SearchDelegate {
  List<String> names = [
    "Farhan",
    "Amir",
    "Rehman",
    "Fahad",
    "Uzair",
    "Hafiz jee",
  ];

  @override
  String get searchFieldLabel => 'Search';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primaryColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[300],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),

        // prefixIcon: Padding(
        //   padding: EdgeInsets.only(left: 15, right: 10),
        //   child: Icon(Icons.search, color: Colors.orange),
        // ),
      ),
    );
  }

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
    return AppBackButton(
      onTap: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final results = provider.users.where((user) {
      return user.username
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          user.nickname.toString().toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final user = results[index];

          return ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage(user.imageUrl.toString()),
              ),
              title: AppTextWidget(
                  text: user.username.toString(),
                  fontSize: 16,
                  textAlign: TextAlign.start,
                  fontWeight: FontWeight.w500),
              subtitle: AppTextWidget(
                text: '${user.nickname} \n${user.followers} Followers',
                fontSize: 10,
                textAlign: TextAlign.start,
                fontWeight: FontWeight.w300,
              ),
              trailing: GestureDetector(
                onTap: () {
                  provider.toggleFollowStatus(user);
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  width: 80,
                  // Set the desired width
                  height: 30,
                  decoration: BoxDecoration(
                      color: user.isFollowing ? Colors.grey : primaryColor,
                      borderRadius: BorderRadius.circular(8)),
                  child: Center(
                    child: Text(
                      user.isFollowing ? 'Following' : 'Follow',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ));
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final results = provider.users.where((user) {
      return user.username
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          user.nickname.toString().toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final user = results[index];

          return ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage(user.imageUrl.toString()),
              ),
              title: AppTextWidget(
                text: user.username.toString(),
                fontSize: 16,
                textAlign: TextAlign.start,
                fontWeight: FontWeight.w500,
              ),
              subtitle: AppTextWidget(
                text: '${user.nickname} \n${user.followers} Followers',
                fontSize: 12,
                textAlign: TextAlign.start,
                fontWeight: FontWeight.w300,
              ),
              trailing: GestureDetector(
                onTap: () {
                  provider.toggleFollowStatus(user);
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  width: 80,
                  height: 30,
                  decoration: BoxDecoration(
                      color: user.isFollowing ? Colors.grey : primaryColor,
                      borderRadius: BorderRadius.circular(8)),
                  child: Center(
                    child: Text(
                      user.isFollowing ? 'Following' : 'Follow',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ));
        });
  }
}
