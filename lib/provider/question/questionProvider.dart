import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http ;

import '../../model/res/constant/app_utils.dart';
import '../action/action_provider.dart';
class QuestionsProvider extends ChangeNotifier{
  final String _cloudName = 'dtwnx4xvs';

  Future<String> uploadFileToCloudinary(
      String filePath, BuildContext context) async {
    try {
      String uploadUrl = "https://api.cloudinary.com/v1_1/$_cloudName/upload";

      var request = http.MultipartRequest('POST',
          Uri.parse(uploadUrl));
      request.fields['api_key'] = '874436973376586';
      request.fields['api_secret'] = 'RBXYDmQuopdKfaEVaoUaKkh789g';
      request.fields['upload_preset'] = 'Article';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      ActionProvider().setLoading(true);
      http.StreamedResponse streamedResponse = await request.send();
      http.Response response =
      await streamedResponse.stream.bytesToString().then((responseBody) {
        return http.Response(responseBody, streamedResponse.statusCode,
            headers: streamedResponse.headers);
      });
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        String uploadedUrl = jsonResponse['secure_url'];

        log('File uploaded successfully to Cloudinary: $uploadedUrl');
        ActionProvider().setLoading(false);
        return uploadedUrl;
      } else {
        ActionProvider().setLoading(false);
        print(
            'Failed to upload file to Cloudinary. Status code: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      ActionProvider().setLoading(false);
      AppUtils().showToast(text:
           'Check your internet connection before try again');
      log('Error uploading file to Cloudinary: $e');
      return '';
    }
  }
}