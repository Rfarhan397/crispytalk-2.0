import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class BuildChatShimmerEffect extends StatelessWidget {
  const BuildChatShimmerEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.w),
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Match background color with your design
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Profile picture shimmer effect with online indicator placeholder
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    color: Colors.grey[400],
                    height: 10.4.w, // CircleAvatar radius * 2
                    width: 10.4.w,
                  ),
                ),
              ),
              SizedBox(width: 1.w),

              // Name and last message shimmer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name shimmer effect
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 1.8.h, // Match the text height of fullName
                        width: 20.w, // Adjust width for name length
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    // Last message shimmer effect
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 1.7.h, // Match the text height of last message
                        width: 20.w, // Adjust width for message length
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 1.w),
              // Time shimmer effect
              Column(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 1.8.h, // Match the text height of timestamp
                      width: 2.w, // Adjust width for time
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
//home first container

class ShimmerContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.3), // Base shimmer color
      highlightColor: Colors.white.withOpacity(0.6), // Highlight shimmer color
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
      ),
    );
  }
}
///suggestion shimmer


class SuggestionCardShimmer extends StatelessWidget {
  const SuggestionCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25.w,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Shimmer for the profile image
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey[300],
            ),
          ),
          SizedBox(height: 0.5.h),
          // Shimmer for the username
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 14.sp,
              width: 60.w,
              color: Colors.grey[300],
            ),
          ),
          SizedBox(height: 0.3.h),
          // Shimmer for the email
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 12.sp,
              width: 80.w,
              color: Colors.grey[300],
            ),
          ),
          SizedBox(height: 1.h),
          // Shimmer for the follow button
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 20.w,
              height: 3.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//post shimmmer
class PostShimmerWidget extends StatelessWidget {
  const PostShimmerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Row with Image and Name
          Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              SizedBox(width: 2.w),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 15.sp,
                  width: 20.w,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          // Caption Placeholder
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 13.sp,
              width: double.infinity,
              color: Colors.grey[300],
            ),
          ),
          SizedBox(height: 1.h),
          // Media Placeholder (Image/Video)
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: 30.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          // Likes and Comments Placeholder
          Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 15,
                  width: 15,
                  color: Colors.grey[300],
                ),
              ),
              SizedBox(width: 1.w),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 12.sp,
                  width: 10.w,
                  color: Colors.grey[300],
                ),
              ),
              SizedBox(width: 3.w),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 15,
                  width: 15,
                  color: Colors.grey[300],
                ),
              ),
              SizedBox(width: 1.w),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 12.sp,
                  width: 10.w,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
//video screen shimmer

class VideoPostShimmerWidget extends StatelessWidget {
  const VideoPostShimmerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Shimmer for Video Player
        Positioned.fill(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              color: Colors.grey[300],
            ),
          ),
        ),
        // Right-side action buttons shimmer
        Positioned(
          right: 10,
          bottom: 8.h,
          child: Column(
            children: [
              // Profile Image Shimmer
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 2.h),

              // Heart Icon Shimmer
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Column(
                  children: [
                    Container(
                      height: 22,
                      width: 22,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 12,
                      width: 20,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Comment Icon Shimmer
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 22,
                  width: 22,
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 20),

              // Share Icon Shimmer
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Column(
                  children: [
                    Container(
                      height: 22,
                      width: 22,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 12,
                      width: 40,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Favorite Icon Shimmer
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Column(
                  children: [
                    Container(
                      height: 22,
                      width: 22,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 12,
                      width: 40,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Bottom-left user details shimmer
        Positioned(
          bottom: 40,
          left: 10,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 18.sp,
                  width: 100.w,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 5),
                Container(
                  height: 14.sp,
                  width: 150.w,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


//CommentShimmerWidget
class CommentShimmerWidget extends StatelessWidget {
  const CommentShimmerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey[300]!,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image Shimmer
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
              ),
            ),
            const SizedBox(width: 8),
            // Comment Content Shimmer
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Username Shimmer
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 16,
                          width: 100,
                          color: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Timestamp Shimmer
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 14,
                          width: 60,
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Comment Text Shimmer
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14,
                          width: double.infinity,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 14,
                          width: MediaQuery.of(context).size.width * 0.6,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
