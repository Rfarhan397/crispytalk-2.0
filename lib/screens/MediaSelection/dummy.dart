// import 'dart:typed_data';
//
// import 'package:crispytalk/constant.dart';
// import 'package:crispytalk/main.dart';
// import 'package:crispytalk/model/res/components/app_button_widget.dart';
// import 'package:crispytalk/model/res/constant/app_assets.dart';
// import 'package:crispytalk/model/res/routes/routes_name.dart';
// import 'package:crispytalk/model/res/widgets/app_text.dart.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:photo_manager/photo_manager.dart';
// import 'package:provider/provider.dart';
// import 'package:sizer/sizer.dart';
// import '../../provider/mediaSelection/mediaSelectionProvider.dart';
//
// class MediaSelectionScreenWrapper extends StatefulWidget {
//   const MediaSelectionScreenWrapper({super.key});
//
//   @override
//   _MediaSelectionScreenWrapperState createState() =>
//       _MediaSelectionScreenWrapperState();
// }
//
// class _MediaSelectionScreenWrapperState
//     extends State<MediaSelectionScreenWrapper>
//     with SingleTickerProviderStateMixin {
//   late MediaSelectionProvider provider;
//
//   @override
//   void initState() {
//     super.initState();
//     provider = MediaSelectionProvider();
//     provider.setTabController(this);
//   }
//
//   @override
//   void dispose() {
//     provider.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider<MediaSelectionProvider>.value(
//       value: provider,
//       child: const MediaSelectionScreen(),
//     );
//   }
// }
//
// class MediaSelectionScreen extends StatelessWidget {
//   const MediaSelectionScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text("Select the photos, videos"),
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           // TabBar for All, Videos, Photos
//           SizedBox(
//             height: 50,
//             child: Consumer<MediaSelectionProvider>(
//               builder: (context, provider, child) {
//                 return TabBar(
//                   controller: provider.tabController,
//                   indicatorColor: Colors.black,
//                   labelColor: Colors.black,
//                   unselectedLabelColor: Colors.grey,
//                   tabs: const [
//                     Tab(text: 'All'),
//                     Tab(text: 'Videos'),
//                     Tab(text: 'Photos'),
//                   ],
//                 );
//               },
//             ),
//           ),
//           // Expanded TabBarView for each tab
//           Expanded(
//             child: Consumer<MediaSelectionProvider>(
//               builder: (context, provider, child) {
//                 return TabBarView(
//                   controller: provider.tabController,
//                   children: [
//                     buildMediaGrid(context, provider.mediaList, provider),
//                     buildMediaGrid(context, provider.videoList, provider),
//                     buildMediaGrid(context, provider.photoList, provider),
//                   ],
//                 );
//               },
//             ),
//           ),
//           // Select Multiple option
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Consumer<MediaSelectionProvider>(
//               builder: (context, provider, child) {
//                 return Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//                             provider.toggleSelectMultiple(!provider.selectMultiple);
//                           },
//                           child: Container(
//                             width: 24.0,
//                             height: 24.0,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: provider.selectMultiple
//                                   ? primaryColor
//                                   : Colors.transparent,
//                             ),
//                             alignment: Alignment.center,
//                             child: provider.selectMultiple
//                                 ? AppTextWidget(
//                               text: '${provider.selectedItems.length}',
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             )
//                                 : Container(
//                               width: 24.0,
//                               height: 24.0,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.transparent,
//                                 border: Border.all(
//                                   width: 2,
//                                   color: primaryColor,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 2.w),
//                         const AppTextWidget(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w400,
//                             text: 'Select Multiple'),
//                       ],
//                     ),
//                     if (provider.selectedItems.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: AppButtonWidget(
//                           onPressed: () {
//                             Get.toNamed(RoutesName.uploadMedia);
//                           },
//                           text: 'Next',
//                           width: 20.w,
//                           height: 4.h,
//                           radius: 8,
//                         ),
//                       ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // GridView for displaying media items
//   Widget buildMediaGrid(BuildContext context, List<AssetEntity> mediaList, MediaSelectionProvider provider) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//       child: GridView.builder(
//         itemCount: mediaList.length,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           crossAxisSpacing: 4,
//           mainAxisSpacing: 4,
//         ),
//         itemBuilder: (context, index) {
//           final media = mediaList[index];
//           return GestureDetector(
//             onTap: () {
//               if (provider.selectMultiple) {
//                 provider.toggleItemSelection(media);
//               } else {
//                 provider.toggleItemSelection(media);
//               }
//             },
//             child: FutureBuilder<Uint8List?>(
//               future: media.thumbnailData,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
//                   return Stack(
//                     children: [
//                       Image.memory(
//                         snapshot.data!,
//                         fit: BoxFit.cover,
//                         width: 100.w,
//                       ),
//                       if (provider.selectedItems.contains(media))
//                         Positioned(
//                           right: 5,
//                           top: 5,
//                           child: Container(
//                             width: 20,
//                             height: 20,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               color: primaryColor,
//                             ),
//                             child: const Icon(
//                               Icons.check,
//                               color: Colors.white,
//                               size: 16,
//                             ),
//                           ),
//                         ),
//                       // Add a play icon for videos
//                       if (media.type == AssetType.video)
//                         Positioned(
//                           right: 5,
//                           bottom: 5,
//                           child: Container(
//                             padding: const EdgeInsets.all(2.0),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               color: Colors.black.withOpacity(0.5),
//                             ),
//                             child: const Icon(
//                               Icons.play_arrow_rounded,
//                               color: primaryColor,
//                               size: 16,
//                             ),
//                           ),
//                         ),
//                     ],
//                   );
//                 } else if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else {
//                   return const Center(child: Text("Failed to load image"));
//                 }
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
//
// }
