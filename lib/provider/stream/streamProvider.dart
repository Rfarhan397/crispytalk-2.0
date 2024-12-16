import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import '../../constant.dart';
import '../../model/chatRoom/chatRoomModel.dart';
import '../../model/mediaPost/mediaPost_model.dart';
import '../../model/user_model/user_model.dart';
import '../../screens/chat/Groups/groupList.dart';

class StreamDataProvider extends ChangeNotifier {
  Stream<List<UserModelT>> getUsers() {
    return FirebaseFirestore.instance.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModelT.fromMap(doc.data());
      }).toList();
    });
  }
  Stream<UserModelT> getSingleUser(String userID) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModelT.fromMap(snapshot.data()!);
      } else {
        throw Exception('User not found');
      }
    });
  }

   Future<UserModelT> getCurrentUser() async{
   final data = await  FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser)
        .get();
   return UserModelT.fromMap(data.data()!);
  }

  // Stream<List<CommentModel>> getComments(postId) {
  //   return FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').snapshots().map((snapshot) {
  //     return snapshot.docs.map((doc) {
  //       return CommentModel.fromMap(doc.data());
  //     }).toList();
  //   });
  // }

  Stream<List<CommentWithUser>> getCommentsWithUserDetails(String postId) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .snapshots()
        .asyncMap((snapshot) async {
      final commentsWithUserDetails = await Future.wait(snapshot.docs.map((doc) async {
        // Get comment data
        final comment = CommentModel.fromMap(doc.data());

        // Get user data using userId from the comment
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(comment.userId).get();
        UserModelT? user;
        if (userDoc.exists) {
          user = UserModelT.fromMap(userDoc.data()!);
        }

        // Return combined comment and user data as CommentWithUser
        return CommentWithUser(comment: comment, user: user!);
      }).toList());

      return commentsWithUserDetails;
    });
  }


  Stream<List<MediaPost>> getPostsWithUserDetails({
    required String currentUserId,
    String? audience,
    String? userStatus,
    bool includeCurrentUser = true, // Default: Include current user's posts
  }) async* {
    List<String> validUserIds = [];
    List<String> blockedUserIds = [];

    try {
      // Fetch blocked user IDs from the current user's block list
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      final currentUserData = currentUserDoc.data() as Map<String, dynamic>?;
      if (currentUserData != null) {
        blockedUserIds = List<String>.from(currentUserData['blocks'] ?? []);
      }

      // Fetch valid user IDs (excluding blocked users)
      Query userQuery = FirebaseFirestore.instance.collection('users');
      userQuery = userQuery.where('blockStatus', isNotEqualTo: 'blockedBy$currentUserId');
      final usersSnapshot = await userQuery.get();

      validUserIds = usersSnapshot.docs
          .map((doc) => doc.id)
          .where((uid) => !blockedUserIds.contains(uid)) // Exclude blocked users
          .toList();
    } catch (e) {
      print('Error fetching valid user IDs: $e');
    }

    Query postsQuery = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timeStamp', descending: true);

    if (audience != null) {
      postsQuery = postsQuery.where('audience', isEqualTo: audience);
    }

    yield* postsQuery.snapshots().asyncMap((snapshot) async {
      try {
        final postUserIds = snapshot.docs
            .map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          return data?['userUid'] as String?;
        })
            .whereType<String>()
            .toSet();

        // Filter user IDs by excluding blocked users and applying valid user check
        final filteredUserIds = postUserIds
            .where((uid) =>
        (includeCurrentUser || uid != currentUserId) && // Exclude current user if false
            validUserIds.contains(uid) && // Only valid user IDs
            !blockedUserIds.contains(uid)) // Exclude blocked users
            .toList();

        List<Map<String, dynamic>> usersData = [];
        for (int i = 0; i < filteredUserIds.length; i += 10) {
          final batchIds = filteredUserIds.sublist(
              i, i + 10 > filteredUserIds.length ? filteredUserIds.length : i + 10);

          final batchUsersSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where(FieldPath.documentId, whereIn: batchIds)
              .get();

          usersData.addAll(batchUsersSnapshot.docs.map((doc) => doc.data()));
        }

        final userMap = {
          for (var user in usersData) user['userUid']: UserModelT.fromMap(user)
        };

        return snapshot.docs.map((doc) {
          final postData = doc.data();
          final mediaPost = MediaPost.fromMap(postData as Map<String, dynamic>);
          mediaPost.userDetails = userMap[mediaPost.userUid];
          return mediaPost;
        }).where((post) => post.userDetails != null).toList();
      } catch (e) {
        print('Error processing posts: $e');
        return [];
      }
    });
  }

  Stream<List<UserModelT>> getBlockedUsers(String userID) async* {
    try {
      // Get the current user's block list
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userID).get();
      if (!userDoc.exists) {
        yield [];
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final blocks = List<String>.from(userData['blocks'] ?? []);

      // Stream all users and filter those in the block list
      yield* FirebaseFirestore.instance.collection('users').snapshots().map((snapshot) {
        return snapshot.docs
            .where((doc) => blocks.contains(doc.id)) // Filter users in the block list
            .map((doc) => UserModelT.fromMap(doc.data()))
            .toList();
      });
    } catch (e) {
      print('Error fetching blocked users: $e');
      yield [];
    }
  }


  Stream<List<UserModelT>> getFollowingUsers(String currentUserId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .snapshots()
        .asyncMap((doc) async {
      // Get the current user's data
      if (!doc.exists) return [];
      final followingList = List<String>.from(doc.data()?['following'] ?? []);

      // Fetch user details for all users in the following list
      final users = await Future.wait(followingList.map((uid) async {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (userDoc.exists) {
          return UserModelT.fromMap(userDoc.data()!);
        }
        return null;
      }));

      // Filter out null entries
      return users.whereType<UserModelT>().toList();
    });
  }
  Future<void> updateFcmToken() async {
    final uid =  currentUser;
    log('message$currentUser');
    String? token = '';
    if (Platform.isAndroid) {
      token = await FirebaseMessaging.instance.getToken();
    }
    if (Platform.isIOS) {
      token = await FirebaseMessaging.instance.getAPNSToken();
    }
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fcmToken': token,
    });
  }


  // Fetch all groups as a stream of Group objects filtered by current user UID
  Stream<List<Group>> getAllGroupsStream(String currentUserUid) {
    return fireStore.collection('groupChats').snapshots().map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) {
        final group = Group.fromFirestore(doc.data() as Map<String, dynamic>);
        // Filter groups where the current user is a member
        return group.members.contains(currentUserUid) ? group : null;
      })
          .where((group) => group != null)
          .cast<Group>()
          .toList();
    });
  }
  // Future<List<GroupUserModel>> getGroupMembers(String groupID) async {
  //   final groupDoc = await FirebaseFirestore.instance
  //       .collection('groupChats')
  //       .doc(groupID)
  //       .get();
  //
  //   final members = groupDoc['members'] as List<dynamic>;
  //
  //   return members.map((member) {
  //     return GroupUserModel(
  //       userUid: member['userUid'],
  //       fcmToken: member['fcmToken'],
  //       name: member['name'],
  //       profileUrl: member['profileUrl'],
  //     );
  //   }).toList();
  // }
  Future<List<GroupUserModel>> getGroupMembers(String groupID) async {
    final groupDoc = await FirebaseFirestore.instance
        .collection('groupChats')
        .doc(groupID)
        .get();

    // Get the list of user UIDs from the group document
    final memberUIDs = List<String>.from(groupDoc['members']);

    // Fetch user details for each UID from the users collection
    List<GroupUserModel> members = [];
    for (String uid in memberUIDs) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        final member = userDoc.data()!;
        members.add(GroupUserModel(
          userUid: member['userUid'],
          fcmToken: member['fcmToken'],
          name: member['name'],
          profileUrl: member['profileUrl'],
        ));
      }
    }

    return members;
  }

  Stream<List<Map<String, dynamic>>> getNotificationsWithUserDetails(String recipientId) {
    return FirebaseFirestore.instance.collection('users').doc(currentUser)
        .collection('notifications')
        .where('recipientId', isEqualTo: recipientId)
        .snapshots()
        .asyncMap((notificationSnapshot) async {
      List<Map<String, dynamic>> notificationsWithUserDetails = [];

      for (var doc in notificationSnapshot.docs) {
        var notificationData = doc.data();
        notificationData['id'] = doc.id;

        // Fetch sender details
        String senderId = notificationData['senderId'];
        DocumentSnapshot senderSnapshot = await FirebaseFirestore.instance.collection('users').doc(senderId).get();

        if (senderSnapshot.exists) {
          var senderData = senderSnapshot.data() as Map<String, dynamic>;
          notificationData['senderName'] = senderData['name'] ?? "Unknown";
          notificationData['senderProfileUrl'] = senderData['profileUrl'] ?? "";
        }

        notificationsWithUserDetails.add(notificationData);
      }

      return notificationsWithUserDetails;
    });
  }
}
