import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crispy/model/services/fcm/fcm_services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../constant.dart';
import '../../model/mediaPost/mediaPost_model.dart';
import '../../model/res/constant/app_utils.dart';
import '../../model/res/routes/routes_name.dart';
import '../../model/services/enum/toastType.dart';
import '../chat/chatProvider.dart';
import '../current_user/current_user_provider.dart';
import '../mediaSelection/mediaSelectionProvider.dart';
import '../savedPost/savedPostProvider.dart';

class ActionProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  final Map<int, bool> _isHovered = {};
  final Map<int, bool> _isLoading = {};
  final ImagePicker _picker = ImagePicker();

  Map<int, bool> _isCardHovered = {};

  bool isCardHovered(int index) => _isCardHovered[index] ?? false;

  void setHover(int index, bool value) {
    _isCardHovered[index] = value;
    notifyListeners();
  }

  static final ActionProvider _instance = ActionProvider._internal();

  factory ActionProvider() => _instance;

  ActionProvider._internal();

  int get selectedIndex => _selectedIndex;

  bool isHovered(int index) => _isHovered[index] ?? false;

  bool isLoading(int index) => _isLoading[index] ?? false;

  void selectMenu(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void onHover(int index, bool isHovered) {
    _isHovered[index] = isHovered;
    notifyListeners();
  }

  void setLoading(bool isLoading) {
    _isLoading[0] = isLoading;
    notifyListeners();
  }

  // Static methods to start and stop loading globally
  static void startLoading() {
    _instance.setLoading(true);
  }

  static void stopLoading() {
    _instance.setLoading(false);
  }

  String? _message;
  bool _isVisible = false;
  ToastType? _toastType;

  String? get message => _message;

  bool get isVisible => _isVisible;

  ToastType? get toastType => _toastType;

  void showToast(String message, ToastType toastType) {
    _message = message;
    _toastType = toastType;
    _isVisible = true;
    notifyListeners();

    // Automatically hide the toast after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      hideToast();
    });
  }

  void hideToast() {
    _isVisible = false;
    notifyListeners();
  }

  final Map<String, bool> _loadingStates = {};

  bool isLoadingState(String key) => _loadingStates[key] ?? false;

  void setLoadingState(String key, bool loading) {
    _loadingStates[key] = loading;
    notifyListeners();
  }

  bool _isFooterHovered = false;

  bool get isFooterHovered => _isFooterHovered;

  void setHovered(bool value) {
    _isFooterHovered = value;
    notifyListeners();
  }

  int _hoveredIndex = -1;

  int get hoveredIndex => _hoveredIndex;

  void setHoveredIndex(int index) {
    _hoveredIndex = index;
    notifyListeners();
  }

  void clearHover() {
    _hoveredIndex = -1;
    notifyListeners();
  }

  bool _isEditVisible = false;

  bool get isEditVisible => _isEditVisible;

  void setEditVisible(bool value) {
    _isEditVisible = value;
    notifyListeners();
  }

  final GlobalKey<ScaffoldState> _scaffoldKeyDashboard =
      GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKeyDashboard;

  void controlMenuDashboard() {
    if (!_scaffoldKeyDashboard.currentState!.isDrawerOpen) {
      _scaffoldKeyDashboard.currentState!.openDrawer();
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKeyInstructor =
      GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKeyInstructor => _scaffoldKeyInstructor;

  void controlMenuInstructor() {
    if (!_scaffoldKeyInstructor.currentState!.isDrawerOpen) {
      _scaffoldKeyInstructor.currentState!.openDrawer();
    }
  }

  // date picker d
  DateTime? _selectedDateTime;

  DateTime? get selectedDateTime => _selectedDateTime;

  void setDateTime(DateTime dateTime) {
    _selectedDateTime = dateTime;
    notifyListeners();
  }

  DateTimeRange? _selectedDateTimeRange;

  DateTimeRange? get selectedDateTimeRange => _selectedDateTimeRange;

  void setDateTimeRange(DateTimeRange dateTimeRange) {
    _selectedDateTimeRange = dateTimeRange;
    notifyListeners();
  }

////// popup menu/////////
  String _selectedItem = ''; // Track selected menu item
  String _selectedProfileItem = ''; // Track selected menu item

  String get selectedItem => _selectedItem;

  String get selectedProfileItem => _selectedProfileItem;

  void setSelectedItem(String item) {
    _selectedItem = item;
    notifyListeners(); // Notify listeners to update UI
  }

  void setSelectedProfileItem(String value) {
    _selectedProfileItem = value;
    notifyListeners(); // Notify listeners to update UI
  }

  ///////////to like and unlike the post //////
  Future<void> likePost(
    String postId,
  ) async {
    final userId = auth.currentUser?.uid.toString() ?? "";

    if (userId.isNotEmpty) {
      DocumentReference likeRef = fireStore.collection('posts').doc(postId);
      await likeRef.update({
        'likes': FieldValue.arrayUnion([userId]),
        'isLiked': true,
      });
    }
  }

  Future<void> unlikePost(String postId) async {
    final userId = auth.currentUser?.uid.toString() ?? "";

    if (userId.isNotEmpty) {
      DocumentReference likeRef = fireStore.collection('posts').doc(postId);
      await likeRef.update({
        'likes': FieldValue.arrayRemove([userId]),
        'isLiked': false,
      });
    }
  }

  // Check if the current user liked the post
  bool isPostLiked(
    String postId,
    List<String> likes,
  ) {
    final userId = auth.currentUser?.uid ?? "";

    return likes.contains(userId);
  }

  // Toggle like/unlike
  Future<void> toggleLike(
    String postId,
    List<String> likes,
  ) async {
    final userId = auth.currentUser?.uid ?? "";
    if (likes.contains(userId)) {
      await unlikePost(postId);
    } else {
      await likePost(
        postId,
      );
    }
    notifyListeners();
  }

  Future<void> savePost(String postId) async {
    final userId = auth.currentUser?.uid.toString() ?? "";

    if (userId.isNotEmpty) {
      DocumentReference saveRef = fireStore.collection('posts').doc(postId);
      await saveRef.update({
        'saves': FieldValue.arrayUnion([userId]),
        'isSaved': true,
      });
      await Provider.of<SavedPostsProvider>(Get.context!, listen: false)
          .refreshSavedPosts(currentUser);
    }
  }

  Future<void> unSavePost(String postId) async {
    final userId = auth.currentUser?.uid.toString() ?? "";

    if (userId.isNotEmpty) {
      DocumentReference unSaveRef = fireStore.collection('posts').doc(postId);
      await unSaveRef.update({
        'saves': FieldValue.arrayRemove([userId]),
        'isSaved': false,
      });
      await Provider.of<SavedPostsProvider>(Get.context!, listen: false)
          .refreshSavedPosts(currentUser);
    }
  }

  // Check if the current user liked the post
  bool isPostSaved(String postId, List<String> saved) {
    final userId = auth.currentUser?.uid ?? "";
    return saved.contains(userId);
  }

  // Toggle
  Future<void> toggleSave(String postId, List<String> saved) async {
    final userId = auth.currentUser?.uid ?? "";
    if (saved.contains(currentUser)) {
      await unSavePost(postId);
    } else {
      await savePost(postId);
    }
    notifyListeners(); // Trigger rebuild to update icon
  }

  //new way
  void toggleSaveNew(String timeStamp, List saves) {
    if (saves.contains(timeStamp)) {
      saves.remove(timeStamp);
    } else {
      saves.add(timeStamp);
    }
    // Notify listeners about the change
    notifyListeners();
  }

////////////to Follow user m firestore //////
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  bool isFollowed(String postId, List<String> Followed) {
    final userId = auth.currentUser?.uid ?? "";
    return Followed.contains(userId);
  }

  // Update followers and following in Firestore
  Future<void> followUser(String userUid, String otherUserUid) async {
    if (currentUser != null) {
      final currentUserId = currentUser!;
      log("Following user: $currentUserId -> $otherUserUid");

      // Add current user's ID to the other user's 'followers' list
      await fireStore.collection('users').doc(otherUserUid).update({
        'followers': FieldValue.arrayUnion([currentUserId]),
      });

      // Add other user's ID to the current user's 'following' list
      await fireStore.collection('users').doc(currentUserId).update({
        'following': FieldValue.arrayUnion([otherUserUid]),
      });
    }
  }

  Future<void> unFollowUser(String currentUserUid, String otherUserUid) async {
    try {
      log("Unfollowing user: $currentUserUid -> $otherUserUid");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserUid)
          .update({
        'followers': FieldValue.arrayRemove([currentUserUid]),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .update({
        'following': FieldValue.arrayRemove([otherUserUid]),
      });
      log("Unfollowed user successfully!");
    } catch (e) {
      log("Error while unfollowing user: $e");
    }
  }

  Future<void> toggleFollow(String userUid, String otherUserUid) async {
    if (currentUser != null) {
      final currentUserId = currentUser!;
      final userSnapshot =
          await fireStore.collection('users').doc(otherUserUid).get();

      // Check if the current user is already following the other user
      final List<dynamic> followers = userSnapshot['followers'] ?? [];

      if (followers.contains(currentUserId)) {
        log("Unfollowing $otherUserUid");
        await unFollowUser(userUid, otherUserUid);
      } else {
        log("Following $otherUserUid");
        await followUser(userUid, otherUserUid);
      }
    }

    notifyListeners();
  }

//////////////who can see this post/////////

  String _selectedOption = 'Everyone';
  String get selectedOption => _selectedOption;

  void selectOption(String option) {
    _selectedOption = option;
    notifyListeners();
  }

  bool isSelected(String option) {
    return _selectedOption == option;
  }

  Uint8List? mediaBytes;
  String? mediaType;
//new
  String? mediaPath;
  String? uploadedMediaUrl;
  String? uploadedMediaName;
  String? uploadedMediaTypee;
  String? uploadedThumbnailUrl; // To store the thumbnail URL

//api start
  Future<void> uploadFile() async {
    log('File path is :: $_filePath');

    try {
      final file = File(_filePath!);
      if (!await file.exists()) {
        log('File does not exist at the specified path.');
        return;
      }
      log('File size: ${await file.length()} bytes');
      log('Uploading file...');

      final Uri uri = Uri.parse("https://Solinovation.finegap.com/media");

      var request = http.MultipartRequest('POST', uri);

      final mimeType = lookupMimeType(_filePath!);
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      ));

      http.StreamedResponse response = await request.send();

      if (response.statusCode != 200) {
        log('Error: ${response.statusCode}');
        throw Exception('File upload failed');
      } else {
        log("${response.statusCode}");
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);
        // New variable to store media type
        String uploadedMediaType;

        // Check if the uploaded URL ends with specific video extensions
        String uploadedUrl = '${jsonResponse['file']['url']}';
        if (uploadedUrl.endsWith('.mp4') ||
            uploadedUrl.endsWith('.mov') ||
            uploadedUrl.endsWith('.avi')) {
          uploadedMediaType = 'mp4';
          // await extractThumbnail(_filePath!);
        } else {
          uploadedMediaType = 'image';
        }
        // save in these variables
        uploadedMediaUrl =
            '${jsonResponse['file']['url']}'; // Replace with actual URL
        uploadedMediaName = '${jsonResponse['file']['name']}';
        uploadedMediaTypee = uploadedMediaType;
      }
    } catch (e) {
      log("RESPONSE:: ${e.toString()}");
      throw "File upload failed:: ${e.toString()}";
    }
  }
  // Future<void> extractThumbnail(String videoPath) async {
  //   final FlutterFFmpeg ffmpeg = FlutterFFmpeg();
  //
  //   // Generate a temporary thumbnail file from the video
  //   final String thumbnailPath = '${Directory.systemTemp.path}/thumbnail.jpg';
  //
  //   // Use ffmpeg to extract the thumbnail (you can adjust the parameters as needed)
  //   await ffmpeg.execute('-i $videoPath -ss 00:00:01.000 -vframes 1 $thumbnailPath');
  //
  //   log("Thumbnail generated at: $thumbnailPath");
  //
  //   // Save the thumbnail URL (locally or elsewhere)
  //   uploadedThumbnailUrl = thumbnailPath;  // Set the local path of the thumbnail
  //
  //   log("Thumbnail saved locally at: $uploadedThumbnailUrl");
  //
  //   // You can now upload the thumbnail to another server or use it locally
  // }

  Future<String> uploadFileThrough(String filePath) async {
    log('File path is :: $filePath');

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        log('File does not exist at the specified path.');
      }
      log('File size: ${await file.length()} bytes');
      log('Uploading file...');

      final Uri uri = Uri.parse("https://Solinovation.finegap.com/media");

      var request = http.MultipartRequest('POST', uri);

      final mimeType = lookupMimeType(filePath);
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      ));

      http.StreamedResponse response = await request.send();

      if (response.statusCode != 200) {
        log('Error: ${response.statusCode}');
        throw Exception('File upload failed');
      } else {
        log("${response.statusCode}");
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);
        // New variable to store media type
        String uploadedMediaType;

        // Check if the uploaded URL ends with specific video extensions
        String uploadedUrl = '${jsonResponse['file']['url']}';
        if (uploadedUrl.endsWith('.mp4') ||
            uploadedUrl.endsWith('.mov') ||
            uploadedUrl.endsWith('.avi')) {
          uploadedMediaType = 'mp4';
        } else {
          uploadedMediaType = 'image';
        }
        // save in these variables
        uploadedMediaUrl =
            '${jsonResponse['file']['url']}'; // Replace with actual URL
        uploadedMediaName = '${jsonResponse['file']['name']}';
        uploadedMediaTypee = uploadedMediaType;
        //saved
        log('Uploaded: ${uploadedMediaUrl}');
        log('Uploaded Media Type: ${uploadedMediaType}');
        log('Uploaded Media Path: ${uploadedUrl}');
        log('Uploaded Media Name: ${uploadedMediaName}');
        log("JsonResponse:: $jsonResponse");
        return jsonResponse['file']['name'];
      }
    } catch (e) {
      log("RESPONSE:: ${e.toString()}");
      throw "File upload failed:: ${e.toString()}";
    }
  }

  //clear uploadedmedaiUrl
  void clearUploadedMediaUrl() {
    uploadedMediaUrl = null;
    uploadedMediaName = null;
    uploadedMediaTypee = null;
  }

  void handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      // Handle successful response
      log("File uploaded successfully: ${response.body}");
    } else {
      // Handle error response
      log("File upload failed with status: ${response.statusCode}");
      throw Exception("File upload failed: ${response.body}");
    }
  }
//   Future<void> uploadFile(Uint8List mediaBytes) async {
//     log('mediaBytes is :: $mediaBytes');
//
//     try {
//       if (mediaBytes == null) return;
//
//       log('uploading file');
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('https://Solinovation.finegap.com/media'), // Ensure this URL is correct
//       );
//
//       // Create a MultipartFile from Uint8List
//       request.files.add(http.MultipartFile.fromBytes(
//         'file',
//         mediaBytes,
//       ));
//
//       // Log request details
//       log('Request URL: ${request.url}');
//       log('Request Files: ${request.files}');
//
//       final response = await request.send();
//
//       log("RESPONSE:: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(await response.stream.bytesToString());
//         log("RESPONSE:: ${jsonResponse}");
//         print('File uploaded successfully');
//       } else {
//         log('File upload failed: ${response.statusCode}'); // Log the status code
//         throw Exception('File upload failed with status: ${response.statusCode}');
//       }
//     } catch (e) {
//       log("RESPONSE:: ${e.toString()}");
//       throw "File upload failed:: ${e.toString()}";
//     }
//   }
  //end

  String? _filePath;

  String? get filePath => _filePath;

  void savePath(path) {
    _filePath = path;
    notifyListeners();
  }

  pickMedia(BuildContext context) async {
    log('enter in pickMedia');

    FilePickerResult? pickMedia = await FilePicker.platform.pickFiles(
      type: FileType.media, // Allow both images and videos
    );

    if (pickMedia == null) {
      log('pickMedia is null');
      _showAlert(
        title: 'Warning!',
        message: 'Please select an image or video!',
      );
    } else {
      log('went into mediaUpload else');

      // Get the file path instead of relying on in-memory bytes
      String? filePath = pickMedia.files.first.path;
      String? mediaType = pickMedia.files.first.extension;

      if (filePath != null) {
        log('File path: $filePath');

        // Read the file bytes manually from the path
        File file = File(filePath);
        savePath(file.path.toString());
        Uint8List mediaBytes = await file.readAsBytes();

        log('File bytes read successfully. Size: ${mediaBytes.length}');
        log('mediaType: $mediaType');

        // Use Provider to initialize the media
        final mediaProvider =
            Provider.of<MediaSelectionProvider>(context, listen: false);
        mediaProvider.initializeMedia(mediaBytes, mediaType!);

        // Navigate to the DisplayMediaScreen
        log('Attempting navigation to DisplayMediaScreen');

        Get.toNamed(RoutesName.showMedia); // Your route name
        // Get.toNamed(RoutesName.uploadMedia);  // Your route name
      } else {
        log('Error: filePath is null');
      }
    }
  }

//////////////add comment to posts//////
  Future<void> addComment(
    String postId,
    String content,
    String token,
    String currentUserName,
    String postOwnerId,
    String notificationBody,
  ) async {
    var id = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc()
        .id;

    final userId = currentUser;
    final comment = CommentModel(
      commentId: id,
      userId: userId,
      content: content,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(id)
        .set(comment.toMap());
    _uploadNotification(
      token,
      currentUserName,
      postOwnerId,
      postId,
      notificationBody,
    );
  }

  /////get comments for a post////////////
  Stream<List<CommentModel>> getComments(String postId) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromMap(doc.data()))
            .toList());
  }

  void _showAlert({required String title, required String message}) {
    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> pickImages(context, docId) async {
    final chatProvider = ChatProvider();
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      chatProvider.sendGroupImageMessages(
        groupID: docId,
        imagePaths: pickedFiles.map((file) => file.path).toList(),
        context: context,
      );
    }
  }

  Future<void> pickImages2(context, docId) async {
    final chatProvider = ChatProvider();
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      chatProvider.sendImageMessages(
        chatId: docId,
        imagePaths: pickedFiles.map((file) => file.path).toList(),
        context: context,
      );
    }
  }

  Future<void> pickSingleImages(context, docId) async {
    final chatProvider = ChatProvider();
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      chatProvider.sendImageMessages(
        chatId: docId,
        imagePaths: pickedFiles.map((file) => file.path).toList(),
        context: context,
      );
    }
  }

  Future<bool?> showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Message'),
          content: const Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Do not delete
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm delete
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void deleteMessage(String collection, messageId, docId) async {
    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(docId) // Replace with the specific chat document ID
          .collection('messages')
          .doc(messageId)
          .delete();
      print('Message deleted successfully');
    } catch (e) {
      print('Failed to delete message: $e');
    }
  }

  Future<void> logout() async {
    try {
      log('Attempting to logout user: $currentUser');
      await FirebaseAuth.instance.signOut();
      log('User successfully logged out.');
      Get.offAllNamed(RoutesName.loginScreen); // Navigate to the login screen
    } catch (error) {
      log('Failed to log out: $error');
    }
  }

  void deleteUser() async {
    try {
      await FirebaseFirestore.instance
          .collection('users') // Firestore collection name
          .doc(currentUser) // The document ID of the user to delete
          .delete();

      Get.back();
      AppUtils().showToast(text: "User removed successfully");
    } catch (e) {
      Get.back();
      AppUtils().showToast(text: "Failed to remove user: $e");
    }
  }

  void _uploadNotification(String token, String currentUserName,
      notificationBody, String postOwnerId, String postId) {
    // Send the notification via FCM
    FCMService().sendNotification(
      token,
      'A New Notification!',
      '$currentUserName $notificationBody',
      currentUser,
    );

    // Save the notification in Firestore
    _saveNotificationToFirestore(
      recipientId: postOwnerId,
      senderId: currentUser,
      message: '$currentUserName liked your post',
      postId: postId,
      type: 'like',
      //save the user name and photo too
    );
  }

  void _saveNotificationToFirestore({
    required String recipientId,
    required String senderId,
    required String message,
    required String postId,
    required String type,
  }) async {
    try {
      var notificationRef = FirebaseFirestore.instance
          .collection('users')
          .doc(recipientId)
          .collection('notifications')
          .doc();

      await notificationRef.set({
        'id': notificationRef.id, // Set the document ID here
        'recipientId': recipientId,
        'senderId': senderId,
        'message': message,
        'postId': postId,
        'type': type,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });
    } catch (e) {
      log('Error saving notification: $e');
    }
  }

  Future<void> removeUser(String currentUserUid, String otherUserUid) async {
    try {
      log("Unfollowing user: $currentUserUid -> $otherUserUid");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .update({
        'followers': FieldValue.arrayRemove([otherUserUid]),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserUid)
          .update({
        'following': FieldValue.arrayRemove([currentUserUid]),
      });

      log("Unfollowed user successfully!");
    } catch (e) {
      log("Error while unfollowing user: $e");
    }
  }

  Future<void> removeComment(String postId, String commentId) async {
    try {
      log('Attempting to delete comment. Post ID: $postId, Comment ID: $commentId');

      await fireStore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      log('Comment deleted successfully: $commentId');
      AppUtils().showToast(text: 'Comment deleted successfully');
    } catch (e) {
      log('Error deleting comment: $e');
      AppUtils().showToast(text: 'Error: $e');
    }
  }

  Future<void> reportUser({
    String? userID,
    String? text,
  }) async {
    try {
      final docRef = FirebaseFirestore.instance.collection("reports").doc();
      await docRef.set({
        'text': text,
        'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
        'reportTo': userID,
        'reportBy': currentUser,
        'docID': docRef.id
      });

      log("Text stored successfully in Firestore.");
    } catch (e) {
      log("Failed to store text in Firestore: $e");
      rethrow;
    }
  }

  final List<MediaPost> _posts = [];

  List<MediaPost> get posts => _posts;

  void saveModel(List<MediaPost> posts) {
    _posts.clear();
    _posts.addAll(posts);
    notifyListeners();
  }

  void toggleListCheck(context, int index, {required ToggleType type}) async {
    await Provider.of<CurrentUserProvider>(context, listen: false)
        .fetchCurrentUserDetails();
    final cUser =
        Provider.of<CurrentUserProvider>(context, listen: false).currentUser;

    switch (type) {
      case ToggleType.like:
        if (_posts[index].likes.contains(currentUser)) {
          log("Remove Likes");
          posts[index].likes.remove(currentUser);
          unlikePost(_posts[index].timeStamp);
        } else {
          log("Add Likes");
          posts[index].likes.add(currentUser);
          likePost(_posts[index].timeStamp);
          FCMService().sendNotification(
              posts[index].userDetails?.fcmToken ?? '',
              'New Notification',
              '${cUser?.name ?? "User"} liked your post',
              currentUser);
          try {
            _saveNotificationToFirestore(
              recipientId: posts[index].userDetails!.userUid,
              senderId: currentUser,
              message: '${cUser?.name} liked your post',
              postId: posts[index].timeStamp,
              type: 'like',
            );
            log("Notification saved successfully for post ID: ${posts[index].timeStamp}");
          } catch (e) {
            log('Error saving notification: $e'); // Log the error
          }
        }
        break;
      case ToggleType.save:
        if (_posts[index].saves.contains(currentUser)) {
          log("Remove saves");
          posts[index].saves.remove(currentUser);
          unSavePost(_posts[index].timeStamp);
        } else {
          log("Add saves");
          posts[index].saves.add(currentUser);
          savePost(_posts[index].timeStamp);

        }
        break;
    }
    notifyListeners();
  }
}
