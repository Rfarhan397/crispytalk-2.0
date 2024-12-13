import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProfileProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  String? _imageUrl = "";

  File? _backgroundImage;
  File? _profileImage;
  bool _isLoading = false;

  File? get backgroundImage => _backgroundImage;
  String? get imageUrl => _imageUrl;
  File? get profileImage => _profileImage;
  bool get isLoading => _isLoading;

  // Method to pick the background image from gallery
  Future<void> pickBackgroundImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _backgroundImage = File(pickedFile.path);
      Get.back();
      notifyListeners();
    }
  }

  // Method to pick the background image from camera
  Future<void> pickBackgroundImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _backgroundImage = File(pickedFile.path);
      Get.back();
      notifyListeners();
    }
  }

  // Method to pick the profile image from gallery
  Future<void> pickProfileImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _profileImage = File(pickedFile.path);
      Get.back();
      notifyListeners();
    }
  }

  // Method to pick the profile image from camera
  Future<void> pickProfileImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _profileImage = File(pickedFile.path);
      Get.back();
      notifyListeners();
    }
  }

  // Method to convert File into Uint8List
  Future<Uint8List> convertFileToUint8List(File file) async {
    try {
      return await file.readAsBytes();
    } catch (e) {
      log("Error converting file to Uint8List: $e");
      rethrow;
    }
  }

  // Method to upload the image to Cloudinary
  Future<void> uploadImage(Uint8List imageBytes, {String type = "no"}) async {
    const String cloudName = 'dtwnx4xvs';
    const String uploadPreset = 'Article';
    const String folderName = 'images';

    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folderName // Add the folder parameter
      ..files.add(http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: '${DateTime.now().millisecondsSinceEpoch.toString()}.jpg'));

    try {
      final response = await request.send();

      log("Status Code:: ${response.statusCode}");
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);
        _imageUrl = jsonResponse['secure_url'];
        log("Image Url:: ${jsonResponse['secure_url']}");

        notifyListeners(); // Notify listeners about the change
      } else {
        final responseBody = await response.stream.bytesToString();
        log("Response Body:: $responseBody");
        throw Exception('Failed to upload image: $responseBody');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Method to upload the profile image
  Future<void> uploadProfileImage() async {
    if (_profileImage == null) {
      log("No profile image selected");
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      // Convert File to Uint8List
      Uint8List imageBytes = await convertFileToUint8List(_profileImage!);

      // Upload the image
      await uploadImage(imageBytes, type: "profile");

      log("Profile image uploaded successfully: $_imageUrl");
    } catch (e) {
      log("Error uploading profile image: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to upload the background image
  Future<void> uploadBackgroundImage() async {
    if (_backgroundImage == null) {
      log("No background image selected");
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      // Convert File to Uint8List
      Uint8List imageBytes = await convertFileToUint8List(_backgroundImage!);

      // Upload the image
      await uploadImage(imageBytes, type: "background");

      log("Background image uploaded successfully: $_imageUrl");
    } catch (e) {
      log("Error uploading background image: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  //clear
  void clear() {
    _backgroundImage = null;
    _profileImage = null;
    _imageUrl = null;
    _selectedGender = '';
    notifyListeners();
  }
  //select gender
  String _selectedGender = ''; // Default value

  String get selectedGender => _selectedGender;

  void setGender(String gender) {
    _selectedGender = gender;
    notifyListeners(); // Notify listeners to rebuild UI
  }
}
