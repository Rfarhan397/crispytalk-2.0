import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../constant.dart';
import '../../model/filterModel/ColorFilters.dart';
import '../../model/res/components/app_back_button.dart';
import '../../model/res/constant/app_assets.dart';
import '../../model/res/widgets/app_text.dart.dart';
import '../../model/res/widgets/button_widget.dart';
import '../../provider/mediaSelection/mediaSelectionProvider.dart';
import '../../model/res/routes/routes_name.dart';

class ShowMedia extends StatefulWidget {
  const ShowMedia({super.key});

  @override
  State<ShowMedia> createState() => _ShowMediaState();
}

class _ShowMediaState extends State<ShowMedia> {
  final GlobalKey _globalKey = GlobalKey(); // Key to capture filtered image
  
  // Move filter lists to static const to avoid recreating on each build
  static const List<ColorFilter> filterList = [
    ColorFilter.matrix([
      0.393, 0.769, 0.189, 0, 0,
      0.349, 0.686, 0.168, 0, 0,
      0.272, 0.534, 0.131, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    ColorFilter.matrix([
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    ColorFilter.matrix([
      1.2, 0, 0, 0, 0,
      0, 1.0, 0, 0, 0,
      0, 0, 0.8, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    ColorFilter.matrix([
      0.8, 0, 0, 0, 0,
      0, 0.8, 0, 0, 0,
      0, 0, 1.2, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    ColorFilter.matrix([
      0.5, 0, 0, 0, 0,
      0, 0.5, 0, 0, 0,
      0, 0, 0.5, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    ColorFilter.matrix([
      1.5, 0, 0, 0, 0,
      0, 1.5, 0, 0, 0,
      0, 0, 1.5, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    ColorFilter.matrix([
      1.5, 0, 0, 0, -0.5,
      0, 1.5, 0, 0, -0.5,
      0, 0, 1.5, 0, -0.5,
      0, 0, 0, 1, 0,
    ]),
    ColorFilter.matrix([
      1.0, 0.1, 0.1, 0, 0,
      0.1, 1.0, 0.1, 0, 0,
      0.1, 0.1, 0.8, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    ColorFilter.matrix([
      0.299, 0.587, 0.114, 0, 0,
      0.299, 0.587, 0.114, 0, 0,
      0.299, 0.587, 0.114, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    ColorFilter.matrix([
      0.8, 0.2, 0.2, 0, 0,
      0.2, 0.8, 0.2, 0, 0,
      0.2, 0.2, 0.8, 0, 0,
      0, 0, 0, 1, 0,
    ]),
  ];

  static const List<String> filterNames = [
    "Sepia",
    "B&W", 
    "Warm",
    "Cool",
    "Dimmed",
    "Brighten",
    "Contrast",
    "Vintage",
    "Mono",
    "Muted",
  ];

  int? _selectedFilterIndex;

  @override
  void dispose() {
    final mediaProvider = Provider.of<MediaSelectionProvider>(context, listen: false);
    if(mediaProvider.chewieController != null) {
      mediaProvider.chewieController!.pause();
    }
    super.dispose();
  }

  Future<void> _captureFilteredImage() async {
    try {
      final mediaProvider = Provider.of<MediaSelectionProvider>(context, listen: false);
      final mediaType = mediaProvider.mediaType;

      if (mediaType == 'jpg' || mediaType == 'png') {
        // Ensure the frame is fully rendered before capturing
        await Future.delayed(const Duration(milliseconds: 100));

        final RenderRepaintBoundary? boundary = _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

        if (boundary != null) {
          final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
          final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

          if (byteData != null) {
            final Uint8List filteredImageBytes = byteData.buffer.asUint8List();
            mediaProvider.setFilteredMediaBytes(filteredImageBytes);
          }
        }
      } else {
        // For video, pause playback and use original bytes
        if(mediaProvider.chewieController != null) {
          mediaProvider.chewieController!.pause();
        }
        mediaProvider.setFilteredMediaBytes(mediaProvider.mediaBytes!);
      }
    } catch (e) {
      log("Error capturing filtered image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaProvider = Provider.of<MediaSelectionProvider>(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: RepaintBoundary(
              key: _globalKey,
              child: _selectedFilterIndex == null
                  ? _buildMediaWidget(mediaProvider)
                  : ColorFiltered(
                      colorFilter: filterList[_selectedFilterIndex!],
                      child: _buildMediaWidget(mediaProvider),
                    ),
            ),
          ),

          // Filter Selection Container
          Positioned(
            bottom: 10.h,
            left: 0,
            right: 0,
            child: filterColorContainer(context),
          ),

          // Navigation buttons
          Positioned(
            top: 3.h,
            left: 2.w,
            right: 4.w,
            child: _buildNavigationButtons(mediaProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaWidget(MediaSelectionProvider mediaProvider) {
    if (mediaProvider.mediaType == null) {
      return const Center(child: Text('No media selected'));
    }

    if (mediaProvider.mediaType == 'jpg' || mediaProvider.mediaType == 'png') {
      return Image.memory(
        mediaProvider.mediaBytes!,
        fit: BoxFit.contain,
        width: 100.w,
        height: 100.h,
      );
    }

    return mediaProvider.chewieController != null
        ? Chewie(controller: mediaProvider.chewieController!)
        : const CircularProgressIndicator(color: primaryColor);
  }

  Widget _buildNavigationButtons(MediaSelectionProvider mediaProvider) {
    return SizedBox(
      width: 100.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const AppBackButton(),
          ButtonWidget(
            text: "Next",
            onClicked: () async {
              await _captureFilteredImage();
              if (mediaProvider.filteredMediaBytes != null && mediaProvider.mediaType != null) {
                Get.toNamed(
                  RoutesName.uploadMedia,
                  arguments: MediaWithFilter(
                    mediaBytes: mediaProvider.filteredMediaBytes!,
                    mediaType: mediaProvider.mediaType!,
                  ),
                );
              }
            },
            width: 20.w,
            height: 5.h,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget filterColorContainer(BuildContext context) {
    return SizedBox(
      height: 12.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filterList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => setState(() => _selectedFilterIndex = index),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              width: 20.w,
              child: Column(
                children: [
                  Expanded(
                    child: ColorFiltered(
                      colorFilter: filterList[index],
                      child: Image.asset(
                        AppAssets.lady,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  AppTextWidget(
                    text: filterNames[index],
                    color: _selectedFilterIndex == index ? Colors.blue : Colors.black,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}