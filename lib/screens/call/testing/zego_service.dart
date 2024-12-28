// lib/zego_service.dart
import 'dart:convert';
import 'dart:developer';
import 'package:crispy/core/base/base_url.dart';
import 'package:http/http.dart' as http;

class ZegoService {
  final String baseUrl = 'https://api.zegocloud.com'; // Replace with the actual base URL
  final String appID = BaseUrl.appID; // Replace with your App ID
  final String appSign = BaseUrl.appSign; // Replace with your App Sign

  Future<void> createRoom(String roomID) async {
    final url = Uri.parse('$baseUrl/v1/room/create'); // Replace with the actual endpoint
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'appID': appID,
        'appSign': appSign,
      },
      body: jsonEncode({
        'roomID': roomID,
      }),
    );

    if (response.statusCode == 200) {
      log('Room created successfully: ${response.body}');
    } else {
      log('Failed to create room: ${response.statusCode} ${response.body}');
    }
  }

// Add more methods for other API calls as needed
}