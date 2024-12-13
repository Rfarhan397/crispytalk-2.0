import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui' as ui;

class MediaSelectionProvider with ChangeNotifier {
  late TabController _tabController;
  bool _selectMultiple = false;
  List<AssetEntity> _mediaList = [];
  List<AssetEntity> _videoList = [];
  List<AssetEntity> _photoList = [];
  List<AssetEntity> _selectedItems = []; // Track selected items

  TabController get tabController => _tabController;
  bool get selectMultiple => _selectMultiple;
  List<AssetEntity> get mediaList => _mediaList;
  List<AssetEntity> get videoList => _videoList;
  List<AssetEntity> get photoList => _photoList;
  List<AssetEntity> get selectedItems => _selectedItems; // Expose selected items

  Uint8List? mediaBytes;
  String? mediaType;
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  File? mediaFile;

  Uint8List? _filteredMediaBytes; // Store filtered media data
  Uint8List? get filteredMediaBytes => _filteredMediaBytes;

  // Initialize the TabController
  void setTabController(TickerProvider tickerProvider) {
    _tabController = TabController(length: 3, vsync: tickerProvider);
    loadMedia();
  }

  // Load media (photos and videos) from gallery
  Future<void> loadMedia() async {
    final PermissionState permissionState = await PhotoManager.requestPermissionExtend();

    if (permissionState.isAuth) {
      // Load images
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );

      if (albums.isNotEmpty) {
        _photoList = await albums[0].getAssetListPaged(page: 0, size: 100); // First page, 100 items
      }

      // Load videos
      albums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
      );

      if (albums.isNotEmpty) {
        _videoList = await albums[0].getAssetListPaged(page: 0, size: 100); // First page, 100 items
      }

      // Combine images and videos into a single list
      _mediaList = [..._photoList, ..._videoList];

      notifyListeners();
    } else {
      log('Permission denied');
    }
  }

  // Toggle the "select multiple" checkbox
  void toggleSelectMultiple(bool value) {
    _selectMultiple = value;
    if (!_selectMultiple) {
      _selectedItems.clear(); // Clear selections when switching off
    }
    notifyListeners();
  }

  // Toggle selection of an item
  void toggleItemSelection(AssetEntity asset) {
    if (_selectedItems.contains(asset)) {
      _selectedItems.remove(asset);
    } else {
      _selectedItems.add(asset);
    }
    notifyListeners();
  }

  // Initialize the media data and handle video playback
  Future<void> initializeMedia(Uint8List bytes, String type) async {
    mediaBytes = bytes;
    mediaType = type;
    log('type in media slectionProvider: $bytes, $mediaType');
    // Check for valid media type
    if (mediaType == 'mp4' || mediaType == 'avi' || mediaType == 'mov') {
      mediaFile = await _saveMediaFileLocally(bytes);
      if (mediaFile != null) {
        try {
          videoPlayerController = VideoPlayerController.file(mediaFile!)
            ..initialize().then((_) {
              chewieController = ChewieController(
                videoPlayerController: videoPlayerController!,
                autoPlay: true,
                looping: false,
                showControls: true,
                allowFullScreen: true,
              );
              notifyListeners();
            }).catchError((error) {
              debugPrint('Error initializing video player: $error');
            });
        } catch (e) {
          debugPrint('Error initializing VideoPlayerController: $e');
        }
      }
    } else {
      debugPrint('Unsupported media type: $mediaType');
    }

    notifyListeners();
  }

  // Function to save media file locally and return the file
  Future<File?> _saveMediaFileLocally(Uint8List bytes) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/temp_media.${mediaType ?? "mp4"}'; // Default to mp4 if type is null
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Error saving media file: $e');
      return null;
    }
  }

  // Capture and apply filter to image
  Future<void> applyFilterToImage(ColorFilter filter) async {
    if (mediaBytes == null || (mediaType != 'jpg' && mediaType != 'png')) {
      return; // Skip if no media or not an image
    }

    final ui.Image image = await _loadImageFromBytes(mediaBytes!);

    // Apply the filter and capture filtered image
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      _filteredMediaBytes = byteData.buffer.asUint8List();
      notifyListeners();
    }
  }

  Future<ui.Image> _loadImageFromBytes(Uint8List bytes) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  ///save filteerd media/////
  Uint8List? _mediaBytes;
  String? _mediaType;
  ChewieController? _chewieController;


  void setFilteredMediaBytes(Uint8List bytes) {
    _filteredMediaBytes = bytes;
    notifyListeners();
  }
}