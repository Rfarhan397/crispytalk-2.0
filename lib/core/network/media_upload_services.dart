
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:crispy/core/base/base_url.dart';
import 'package:crispy/core/base/end_point.dart';
import 'package:crispy/core/network/apiServices.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart';

class MediaUploadServices{


  final apiServices = ApiService();



  Future<void> uploadVideo(File path) async{


    try{


      final map = {
        'file':path.path,
      };


      final headers = {
        'Content-Type': 'application/json',
      };


      final response = await ApiService.multipartPost(
          endPoint: EndPoint.media,
          headers: headers,
          fields: map
      );


      log("STATUS Code:: ${response.statusCode}");
      if(response.statusCode == 200){
        final jsonResponse = json.decode(await response.stream.bytesToString());
        log("Body: ${jsonResponse}");
        log("Body: ${jsonResponse.body}");

      }

    }catch (e){
      throw "error :$e";
    }

}

}