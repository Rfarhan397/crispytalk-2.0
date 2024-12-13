import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../constant.dart';
import '../../model/chatFriendData/chatFriendDataModel.dart';
import '../../model/chatMessage/chatMessageModel.dart';
import '../../model/chatRoom/chatRoomModel.dart';
import '../../model/res/constant/app_utils.dart';
import '../../model/res/routes/routes_name.dart';
import '../../model/user_model/user_model.dart';
import '../question/questionProvider.dart';

class ChatProvider with ChangeNotifier {
  final _chats = FirebaseFirestore.instance.collection('chats');
  final _users = FirebaseFirestore.instance.collection('users');
  bool _isLoading = false;
  String _chatID = '';

  FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _audioPath;

  bool get isRecording => _isRecording;

  bool get isLoading => _isLoading;
  String get chatID => _chatID;

  Future<void> getChatID({
    required String friendId,
    required BuildContext context,
    required String? image,
    required String? name,
    required String? fcmToken,
    required bool? status,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      setLoading(true);
      // final friendData = await getFriendData(friendId);
      _chats
          .where('users', arrayContains: uid)
          .get()
          .then((QuerySnapshot snapshot) async {
        QueryDocumentSnapshot<Object?>? existingChat;

        for (var doc in snapshot.docs) {
          List<dynamic> users = doc['users'];
          if (users.contains(friendId)) {
            existingChat = doc;
            break;
          }
        }

        if (existingChat != null) {
          log('chat room id is ${existingChat.id}');
          final chat = ChatRoomModel(
              docId: existingChat.id,
              users: [uid, friendId],
              lastMessage: '',
              createdAt: '');
          Get.toNamed(RoutesName.chatScreen,
              arguments: {'image': image,'name':name, 'chat': chat,'isOnline': status,'fcmToken':fcmToken});
        } else {
          _chats.add({
            'users': [uid, friendId],
            'createdAt': DateTime.now().toString(),
            'lastMessage': 'No messages available',

          }).then((value) {
            final chat = ChatRoomModel(
                docId: value.id,
                users: [uid, friendId],
                lastMessage: 'No messages available',
                createdAt: '');
            Get.toNamed(RoutesName.chatScreen,
                arguments: {'image': image,'name':name, 'chat': chat,'isOnline': status,'fcmToken':fcmToken});
          });
        }
        setLoading(false);
      }).catchError((error) {
        setLoading(false);
        AppUtils().showToast(text: 'Something went wrong, please try again');

      });

      notifyListeners();
    } on Exception {
      AppUtils().showToast(text: 'Something went wrong, please try again');

      setLoading(false);
    }
  }

  Future<ChatFriendData> getFriendData(String friendId) async {
    final data = await FirebaseFirestore.instance
        .collection('users')
        .doc(friendId)
        .get();
    return ChatFriendData.fromFirestore(data.data());
  }


  Stream<List<MessageModel>> getMessages(String chatID) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatID)
        .collection('messages').orderBy('createdAt',descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromFirestore(doc);
      }).toList();
    });
  }


  Stream<List<ChatRoomModel>> getChatRooms() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _chats.where('users', arrayContains: uid).snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => ChatRoomModel.fromMap(doc.data(), doc.id),
      )
          .toList(),
    );
  }


  // Stream<List<ChatWithUser>> getChatsWithUserDetails(String chatId,) {
  //   return FirebaseFirestore.instance
  //       .collection('chats')
  //       .doc(chatId)
  //       .collection('messages')
  //       .snapshots()
  //       .asyncMap((snapshot) async {
  //     final chatsWithUserDetails = await Future.wait(snapshot.docs.map((doc) async {
  //       // Get chat message data
  //       final chatMessage = ChatRoomModel.fromMap(doc.data(),'docId');
  //
  //       // Get user data using userId from the chat message
  //       final userDoc = await FirebaseFirestore.instance.collection('users').doc(chatMessage.docId).get();
  //       UserModelT? user;
  //       if (userDoc.exists) {
  //         user = UserModelT.fromMap(userDoc.data()!);
  //       }
  //
  //       // Return combined chat message and user data as ChatWithUser
  //       return ChatWithUser(chatRoomModel: chatMessage, user: user!);
  //     }).toList());
  //
  //     return chatsWithUserDetails;
  //   });
  // }


  void sendTextMessage({required String chatId, required String message}) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(MessageModel(
        message: message,
        createdAt: DateTime.now().toString(),
        type: 'text',
        senderId: uid)
        .toMap());
    FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'lastMessage': message,
      'createdAt': DateTime.now().toString(),
    });

    notifyListeners();
  }
  void sendGroupTextMessage({required String groupID, required String message}) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('groupChats')
        .doc(groupID)
        .collection('messages')
        .add(MessageModel(
        message: message,
        createdAt: DateTime.now().toString(),
        type: 'text',
        senderId: uid)
        .toMap());
    FirebaseFirestore.instance.collection('groupChats').doc(groupID).update({
      'lastMessage': message,
      'createdAt': DateTime.now().toString(),
    });

    notifyListeners();
  }
  Stream<List<MessageModel>> getGroupMessages(String groupID) {
    return FirebaseFirestore.instance
        .collection('groupChats')
        .doc(groupID)
        .collection('messages').orderBy('createdAt',descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromFirestore(doc);
      }).toList();
    });
  }

  void sendGroupImageMessages({
    required String groupID,
    required List<String> imagePaths,
    required BuildContext context,
  }) async {
    setLoading(true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final questionProvider = Provider.of<QuestionsProvider>(context, listen: false);

      for (String imagePath in imagePaths) {
        final url =
        await questionProvider.uploadFileToCloudinary(imagePath, context);

        await FirebaseFirestore.instance
            .collection('groupChats')
            .doc(groupID)
            .collection('messages')
            .add(
          MessageModel(
            message: url,
            createdAt: DateTime.now().toString(),
            type: 'image',
            senderId: uid,
          ).toMap(),
        );

        await FirebaseFirestore.instance
            .collection('groupChats')
            .doc(groupID)
            .update({
          'lastMessage': 'Image',
          'createdAt': DateTime.now().toString(),
        });
      }
    } catch (e) {
      AppUtils().showToast(text: 'Failed to send images, please try again');

    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  void sendImageMessages({
    required String chatId,
    required List<String> imagePaths,
    required BuildContext context,
  }) async {
    setLoading(true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final questionProvider = Provider.of<QuestionsProvider>(context, listen: false);

      for (String imagePath in imagePaths) {
        final url =
        await questionProvider.uploadFileToCloudinary(imagePath, context);

        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .add(
          MessageModel(
            message: url,
            createdAt: DateTime.now().toString(),
            type: 'image',
            senderId: uid,
          ).toMap(),
        );

        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .update({
          'lastMessage': 'Image',
          'createdAt': DateTime.now().toString(),
        });
      }
    } catch (e) {
      AppUtils().showToast(text: 'Failed to send images, please try again');

    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> startRecording() async {
    setLoading(true);
    try {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission denied');
      }

      final directory = await getTemporaryDirectory();
      _audioPath = '${directory.path}/audio_message.aac';

      await _audioRecorder.openRecorder();
      await _audioRecorder
          .setSubscriptionDuration(const Duration(milliseconds: 50));
      await _audioRecorder.startRecorder(
        toFile: _audioPath,
        codec: Codec.aacADTS,
      );

      _isRecording = true;
      notifyListeners();
    } catch (e) {
      log('Error starting recording: $e');
    } finally {
      setLoading(false);
    }
  }
  Future<void> stopRecording2(
      {required String chatId, required BuildContext context}) async {
    setLoading(true);
    try {
      await _audioRecorder.stopRecorder();
      _isRecording = false;

      if (_audioPath != null) {
        final audioUrl = await uploadAudioFile(_audioPath!, context);
        sendAudioMessage(chatId: chatId, audioUrl: audioUrl);
      }
    } catch (e) {
      log('Error stopping recording or uploading file: $e');
    } finally {
      setLoading(false);
    }
    notifyListeners();
  }

  Future<void> stopRecording(
      {required String chatId, required BuildContext context}) async {
    setLoading(true);
    try {
      await _audioRecorder.stopRecorder();
      _isRecording = false;

      if (_audioPath != null) {
        final audioUrl = await uploadAudioFile(_audioPath!, context);
        sendGroupAudioMessage(chatId: chatId, audioUrl: audioUrl);
      }
    } catch (e) {
      log('Error stopping recording or uploading file: $e');
    } finally {
      setLoading(false);
    }
    notifyListeners();
  }

  Future<String> uploadAudioFile(String path, BuildContext context) async {
    try {
      setLoading(true);
      final questionProvider =
      Provider.of<QuestionsProvider>(context, listen: false);
      return await questionProvider.uploadFileToCloudinary(path, context);
    } catch (e) {
      log('Error uploading audio file: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  void sendAudioMessage({required String chatId, required String audioUrl}) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(
      MessageModel(
          message: audioUrl,
          createdAt: DateTime.now().toString(),
          type: 'audio',
          senderId: uid)
          .toMap(),
    );
    FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'lastMessage': 'Audio message',
      'createdAt': DateTime.now().toString(),
    });
    notifyListeners();
  }
  void sendGroupAudioMessage({required String chatId, required String audioUrl}) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('groupChats')
        .doc(chatId)
        .collection('messages')
        .add(
      MessageModel(
          message: audioUrl,
          createdAt: DateTime.now().toString(),
          type: 'audio',
          senderId: uid)
          .toMap(),
    );
    FirebaseFirestore.instance.collection('groupChats').doc(chatId).update({
      'lastMessage': 'Audio message',
      'createdAt': DateTime.now().toString(),
    });
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}