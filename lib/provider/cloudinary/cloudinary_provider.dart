import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';  // Add this line



class CloudinaryProvider with ChangeNotifier {
  final String _cloudName = 'dtwnx4xvs';
  final String _uploadPreset = 'Article';
  String _mediaUrl = '';
  Uint8List? _mediaData;


  String get mediaUrl => _mediaUrl;
  Uint8List? get mediaData => _mediaData;

  // Set media data and notify listeners
  void setMediaData(Uint8List data) {
    _mediaData = data;
    notifyListeners();
  }

  // Clear media and notify listeners
  void clearMedia() {
    _mediaData = null;
    notifyListeners();
  }

  // Function to upload media to Cloudinary
  Future<void> uploadMedia(Uint8List mediaBytes, String mediaType) async {
    log("mediaType in uploadMedia is::$mediaType");

    if (mediaBytes.isEmpty) {
      log("Media bytes are empty.");
      throw Exception('Media bytes are empty');
    }

    // Log first few bytes for debugging
    log("First few bytes of media: ${mediaBytes.take(10).toList()}");
    log("mediaBytes length: ${mediaBytes.length}");

    String endpoint;
    String filename;

    // Validate media type and set endpoint
    if (['mp4', 'avi', 'mov'].contains(mediaType.toLowerCase())) {
      // Video upload endpoint
      endpoint = 'https://api.cloudinary.com/v1_1/$_cloudName/video/upload';
      filename = 'media.$mediaType';
    } else if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(mediaType.toLowerCase())) {
      // Image upload endpoint
      endpoint = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';
      filename = 'media.$mediaType';
    } else {
      log("Unsupported media type: $mediaType");
      throw Exception('Unsupported media type: $mediaType');
    }

    log("Using endpoint: $endpoint");
    log("Preparing to upload: Media type: $mediaType, Size: ${mediaBytes.length} bytes");

    final request = http.MultipartRequest('POST', Uri.parse(endpoint))
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = 'media'
      ..files.add(http.MultipartFile.fromBytes('file', mediaBytes, filename: filename));

    try {
      final response = await request.send();
      log("Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);
        log("Full response from Cloudinary: $responseBody");
        log("Parsed JSON Response: $jsonResponse");

        // Retrieve the media URL
        _mediaUrl = jsonResponse['secure_url'];
        log("Media URL: $_mediaUrl");
      } else {
        final responseBody = await response.stream.bytesToString();
        log("Error Response Body: $responseBody");
        throw Exception('Failed to upload media: $responseBody');
      }
    } catch (e) {
      log("Upload Exception: $e");
      throw Exception('Failed to upload media: $e');
    } finally {
      notifyListeners();
    }
  }
  Future<String?> uploadFile(File file) async {
    try {
      String uploadUrl = "https://api.cloudinary.com/v1_1/$_cloudName/upload";

      // Determine file mime type
      String? mimeType = lookupMimeType(file.path);
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      // Add file and required params
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,  // Use MIME type
      ));
      request.fields['upload_preset'] = _uploadPreset;  // Replace with your upload preset if needed

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var data = json.decode(responseData.body);
        return data['secure_url']; // Get the URL of the uploaded file
      } else {
        throw Exception("Failed to upload file");
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}
