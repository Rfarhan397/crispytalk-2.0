import 'dart:developer';
import 'dart:io';
import 'package:crispy/constant.dart';
import 'package:crispy/model/res/constant/app_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/app_text.dart.dart';

class FullImagePreview extends StatefulWidget {
  final String image;
  const FullImagePreview({super.key, required this.image});

  @override
  State<FullImagePreview> createState() => _FullImagePreviewState();
}

class _FullImagePreviewState extends State<FullImagePreview> {
  bool _isDownloading = false;

  Future<void> _downloadImage() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }

      // Get the downloads directory
      final dir = await getExternalStorageDirectory();
      if (dir == null) throw Exception('Could not access storage');
      
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${dir.path}/$fileName';

      await Dio().download(widget.image, filePath);
      AppUtils().showToast(text: 'Image downloaded to: $filePath');
      log('Image downloaded to: $filePath');
    } catch (e) {
      AppUtils().showToast(text:'Failed to download: ${e.toString()}');
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          _isDownloading
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _downloadImage,
                )
        ],
      ),
      body: Image.network(
        widget.image,
        height: double.infinity,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const AppTextWidget(
            text: 'Error: Failed to load image',
          );
        },
      ),
    );
  }
}
