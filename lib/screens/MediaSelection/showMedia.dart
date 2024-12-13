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

  List<ColorFilter> filterList = [
    const ColorFilter.matrix([
      0.393, 0.769, 0.189, 0, 0,
      0.349, 0.686, 0.168, 0, 0,
      0.272, 0.534, 0.131, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    const ColorFilter.matrix([
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    const ColorFilter.matrix([
      1.2, 0, 0, 0, 0,
      0, 1.0, 0, 0, 0,
      0, 0, 0.8, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    const ColorFilter.matrix([
      0.8, 0, 0, 0, 0,
      0, 0.8, 0, 0, 0,
      0, 0, 1.2, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    const ColorFilter.matrix([
      0.5, 0, 0, 0, 0,
      0, 0.5, 0, 0, 0,
      0, 0, 0.5, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    const ColorFilter.matrix([
      1.5, 0, 0, 0, 0,
      0, 1.5, 0, 0, 0,
      0, 0, 1.5, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    const ColorFilter.matrix([
      1.5, 0, 0, 0, -0.5,
      0, 1.5, 0, 0, -0.5,
      0, 0, 1.5, 0, -0.5,
      0, 0, 0, 1, 0,
    ]),
    const ColorFilter.matrix([
      1.0, 0.1, 0.1, 0, 0,
      0.1, 1.0, 0.1, 0, 0,
      0.1, 0.1, 0.8, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    const ColorFilter.matrix([
      0.299, 0.587, 0.114, 0, 0,
      0.299, 0.587, 0.114, 0, 0,
      0.299, 0.587, 0.114, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    const ColorFilter.matrix([
      0.8, 0.2, 0.2, 0, 0,
      0.2, 0.8, 0.2, 0, 0,
      0.2, 0.2, 0.8, 0, 0,
      0, 0, 0, 1, 0,
    ]),
  ];

  List<String> filterNames = [
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

  Future<void> _captureFilteredImage() async {
    try {
      final mediaType = Provider.of<MediaSelectionProvider>(context, listen: false).mediaType;

      if (mediaType == 'jpg' || mediaType == 'png') {
        // Ensure the frame is fully rendered before capturing
        await Future.delayed(const Duration(milliseconds: 100));

        final RenderRepaintBoundary boundary = _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;

        if (boundary != null) {
          ui.Image image = await boundary.toImage(pixelRatio: 2.0);
          ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

          if (byteData != null) {
            final Uint8List filteredImageBytes = byteData.buffer.asUint8List();

            // Log captured bytes length to check if non-null
            log('Captured filtered image bytes length: ${filteredImageBytes.length}');

            Provider.of<MediaSelectionProvider>(context, listen: false).setFilteredMediaBytes(filteredImageBytes);
          } else {
            log("ByteData is null");
          }
        } else {
          log("Boundary is null, could not capture image.");
        }
      } else {
        // If it’s a video, no filter is applied, use the original media bytes
        final mediaBytes = Provider.of<MediaSelectionProvider>(context, listen: false).mediaBytes;
        Provider.of<MediaSelectionProvider>(context, listen: false).setFilteredMediaBytes(mediaBytes!);
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
          // Media Display Area wrapped in RepaintBoundary to capture filtered image
          Positioned.fill(
            child: RepaintBoundary(
              key: _globalKey,
              child: _selectedFilterIndex == null
                  ? mediaProvider.mediaType != null
                  ? (mediaProvider.mediaType == 'jpg' || mediaProvider.mediaType == 'png')
                  ? Image.memory(
                mediaProvider.mediaBytes!,
                fit: BoxFit.contain,
                width: 100.w,
                height: 100.h,
              )
                  : mediaProvider.chewieController != null
                  ? Chewie(controller: mediaProvider.chewieController!)
                  : const CircularProgressIndicator(color: primaryColor)
                  : const Center(child: Text('No media selected'))
                  : ColorFiltered(
                colorFilter: filterList[_selectedFilterIndex!],
                child: mediaProvider.mediaType != null
                    ? (mediaProvider.mediaType == 'jpg' || mediaProvider.mediaType == 'png')
                    ? Image.memory(
                  mediaProvider.mediaBytes!,
                  fit: BoxFit.contain,
                  width: 100.w,
                  height: 100.h,
                )
                    : mediaProvider.chewieController != null
                    ? Chewie(controller: mediaProvider.chewieController!)
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppTextWidget(text: 'Loading...'),
                        const CircularProgressIndicator(color: primaryColor),
                      ],
                    )
                    : const Center(child: Text('No media selected')),
              ),
            ),
          ),

          // Filter Selection Container (Positioned near bottom)
          Positioned(
            bottom: 10.h,
            left: 0,
            right: 0,
            child: filterColorContainer(context),
          ),

          // "Next" Button Positioned at the Top-Right
          Positioned(
            top: 3.h,
            left: 2.w,
            right: 4.w,
            child: Container(
              width: 100.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppBackButton(),
                  ButtonWidget(
                    text: "Next",
                    onClicked: () async {
                      await _captureFilteredImage();
                      if (mediaProvider.filteredMediaBytes != null && mediaProvider.mediaType != null) {
                        Get.toNamed(
                          RoutesName.uploadMedia,
                          arguments: MediaWithFilter(
                            mediaBytes: mediaProvider.filteredMediaBytes! ,
                            mediaType: mediaProvider.mediaType!,
                          ),
                        );
                        log('${mediaProvider.mediaType!} media type ',);
                        log('filter media is::${mediaProvider.filteredMediaBytes!} ',);
                        log('${mediaProvider.mediaType!} media type ',);
                      }
                    },
                    width: 20.w,
                    height: 5.h,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Filter selector container with each filter thumbnail and label
  Widget filterColorContainer(BuildContext context) {
    return Container(
      height: 12.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filterList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilterIndex = index;
              });
            },
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
                    text:
                    filterNames[index],
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