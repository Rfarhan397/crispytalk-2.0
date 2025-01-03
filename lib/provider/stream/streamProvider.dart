import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import '../../constant.dart';
import '../../model/chatRoom/chatRoomModel.dart';
import '../../model/mediaPost/mediaPost_model.dart';
import '../../model/notification/notificationModel.dart';
import '../../model/user_model/user_model.dart';
import '../../screens/chat/Groups/groupList.dart';

class StreamDataProvider extends ChangeNotifier {
  Stream<List<UserModelT>> getUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((snapshot) {
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

  Future<UserModelT> getCurrentUser() async {
    final data = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser)
        .get();
    return UserModelT.fromMap(data.data()!);
  }

  Stream<List<CommentWithUser>> getCommentsWithUserDetails(String postId) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .snapshots()
        .asyncMap((snapshot) async {
      final commentsWithUserDetails =
          await Future.wait(snapshot.docs.map((doc) async {
        // Get comment data
        final comment = CommentModel.fromMap(doc.data());

        // Get user data using userId from the comment
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(comment.userId)
            .get();
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
  //30/12/24
  Stream<List<MediaPost>> fetchPostsWithUserDetails(String currentUserUid) async* {
    final postsCollection = FirebaseFirestore.instance.collection('posts');
    final usersCollection = FirebaseFirestore.instance.collection('users');

    await for (var postSnapshot in postsCollection.snapshots()) {
      final posts = postSnapshot.docs
          .map((doc) => MediaPost.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      final filteredPosts = <MediaPost>[];

      for (var post in posts) {
        if (post.audience != "Everyone") continue;
        final userDoc = await usersCollection.doc(post.userUid).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final user = UserModelT.fromMap(userData);

          // Skip posts if the user is blocked
          if (!(user.blocks.contains(currentUserUid) ?? false)) {
            filteredPosts.add(post);
          }
        }
      }

      yield filteredPosts;
    }
  }


  Stream<List<MediaPost>> getPostsWithUserDetails({
    required String currentUserId,
    String? audience,
    String? userStatus,
    bool includeCurrentUser = true,
  }) async* {
    try {
      // Fetch current user's block list
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      final currentUserData = currentUserDoc.data() as Map<String, dynamic>?;
      final blockedUserIds =
          List<String>.from(currentUserData?['blocks'] ?? []);

      // Create base query for posts
      Query postsQuery = FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timeStamp', descending: true);

      if (audience != null) {
        postsQuery = postsQuery.where('audience', isEqualTo: audience);
      }

      yield* postsQuery.snapshots().asyncMap((snapshot) async {
        try {
          // Get unique user IDs from posts, excluding blocked users
          final postUserIds = snapshot.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>?;
                return data?['userUid'] as String?;
              })
              .whereType<String>()
              .where((uid) => !blockedUserIds.contains(uid))
              .where((uid) => includeCurrentUser || uid != currentUserId)
              .toSet();

          if (postUserIds.isEmpty) {
            return [];
          }

          // Fetch user details in batches

          List<Map<String, dynamic>> usersData = [];
          for (int i = 0; i < postUserIds.length; i += 10) {
            final batchIds = postUserIds.toList().sublist(
                i, i + 10 > postUserIds.length ? postUserIds.length : i + 10);

            final batchUsersSnapshot = await FirebaseFirestore.instance
                .collection('users')
                .where(FieldPath.documentId, whereIn: batchIds)
                .get();

            usersData.addAll(batchUsersSnapshot.docs.map((doc) => doc.data()));
          }

          // Create map of user details
          final userMap = {
            for (var user in usersData)
              user['userUid']: UserModelT.fromMap(user)
          };

          // Map posts with user details
          return snapshot.docs
              .map((doc) {
                final postData = doc.data();
                final userUid =
                    (postData as Map<String, dynamic>)['userUid'] as String?;

                // Skip posts from blocked users
                if (userUid == null || blockedUserIds.contains(userUid)) {
                  return null;
                }

                final mediaPost =
                    MediaPost.fromMap(postData as Map<String, dynamic>);
                mediaPost.userDetails = userMap[mediaPost.userUid];
                return mediaPost;
              })
              .whereType<MediaPost>() // Remove null entries
              .where((post) => post.userDetails != null)
              .toList();
        } catch (e) {
          print('Error processing posts: $e');
          return [];
        }
      });
    } catch (e) {
      print('Error in getPostsWithUserDetails: $e');
      yield [];
    }
  }

  //fetch postsWithUserDetails from firebase
  Stream<List<MediaPost>> getSinglePostsWithUserDetails() {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('userUid', isEqualTo: currentUser)
        .snapshots()
        .asyncMap((querySnapshot) async {
      List<MediaPost> posts = [];

      for (var doc in querySnapshot.docs) {
        final post = MediaPost.fromMap(doc.data());

        // Fetch user details
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(post.userUid)
            .get();

        if (userDoc.exists) {
          final userDetails = UserModelT.fromMap(userDoc.data()!);
          post.userDetails = userDetails;
        }

        posts.add(post);
      }

      return posts;
    });
  }
  Stream<List<MediaPost>> getFriendsPostsStream() {
    final postsCollection = FirebaseFirestore.instance.collection('posts');

    return postsCollection
        .where('audience', isEqualTo: 'Friends')
        .snapshots()
        .asyncMap((querySnapshot) async {
      List<MediaPost> mediaPosts = querySnapshot.docs.map((doc) {
        return MediaPost.fromMap(doc.data());
      }).toList();

      // Fetch current user's data
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser)
          .get();
      final followingList = List<String>.from(currentUserDoc.data()?['following'] ?? []);
      final blockedUserIds = List<String>.from(currentUserDoc.data()?['blocks'] ?? []); // Fetch block list

      // Fetch user details for each MediaPost
      for (var post in mediaPosts) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(post.userUid)
            .get();

        if (userDoc.exists) {
          post.userDetails = UserModelT.fromMap(userDoc.data()!);
        }
      }

      // Filter posts to only include those from users in the following list and not in the block list
      mediaPosts = mediaPosts.where((post) =>
          followingList.contains(post.userUid) && !blockedUserIds.contains(post.userUid)).toList();

      return mediaPosts;
    });
  }
  Stream<List<UserModelT>> getBlockedUsers(String userID) async* {
    try {
      // Get the current user's block list
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .get();
      if (!userDoc.exists) {
        yield [];
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final blocks = List<String>.from(userData['blocks'] ?? []);

      // Stream all users and filter those in the block list
      yield* FirebaseFirestore.instance
          .collection('users')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .where((doc) =>
                blocks.contains(doc.id)) // Filter users in the block list
            .map((doc) => UserModelT.fromMap(doc.data()))
            .toList();
      });
    } catch (e) {
      print('Error fetching blocked users: $e');
      yield [];
    }
  }
  ///get friends video

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
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
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
    final uid = currentUser;
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
            final group =
                Group.fromFirestore(doc.data() as Map<String, dynamic>);
            return group.members.contains(currentUserUid) ? group : null;
          })
          .where((group) => group != null)
          .cast<Group>()
          .toList();
    });
  }

  Future<List<GroupUserModel>> getGroupMembers(String groupID) async {
    final groupDoc = await FirebaseFirestore.instance
        .collection('groupChats')
        .doc(groupID)
        .get();

    final memberUIDs = List<String>.from(groupDoc['members']);

    // Fetch user details for each UID from the users collection
    List<GroupUserModel> members = [];
    for (String uid in memberUIDs) {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

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

  Stream<List<Map<String, dynamic>>> getNotificationsWithUserDetails(
      String recipientId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser)
        .collection('notifications')
        .snapshots()
        .asyncMap((notificationSnapshot) async {
      List<Map<String, dynamic>> notificationsWithUserDetails = [];

      for (var doc in notificationSnapshot.docs) {
        var notificationData = doc.data();
        notificationData['id'] = doc.id;

        // Fetch sender details
        String senderId = notificationData['senderId'];
        DocumentSnapshot senderSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(senderId)
            .get();

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

  //current user followers
  Stream<List<UserModelT>> fetchCurrentUserFollowers(userUid, followType) {
    return FirebaseFirestore.instance
        .collection('users') // Go to users collection
        .doc(userUid) // Fetch the current user's document
        .snapshots() // Stream of the document
        .asyncMap((snapshot) async {
      if (!snapshot.exists || snapshot.data() == null) {
        return [];
      }

      // Extract followers list (array of UIDs)
      List<dynamic> followersUids = snapshot.data()![followType] ?? [];

      // Fetch details of all users in the followers list
      List<UserModelT> followersList = [];
      for (String uid in followersUids) {
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          followersList.add(UserModelT.fromMap(userDoc.data()!));
        }
      }

      return followersList; // Return the list of followers' details
    });
  }
  Stream<List<Map<String, dynamic>>> getNotifications() async* {
    final notificationsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser)
        .collection('notifications');

    yield* notificationsCollection.snapshots().asyncMap((snapshot) async {
      final notifications = snapshot.docs.map((doc) {
        return NotificationModel.fromMap(doc.data());
      }).toList();

      final enrichedNotifications = await Future.wait(notifications.map((notification) async {
        // Get sender details
        final senderDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(notification.senderId)
            .get();
        final senderData = UserModelT.fromMap(senderDoc.data()!);

        // Get post details
        final postDoc = await FirebaseFirestore.instance
            .collection('posts')
            .doc(notification.postId)
            .get();
        final postData = MediaPost.fromMap(postDoc.data()!);
        // postDoc.data();

        return {
          'notification': notification,
          'sender': senderData,
          'post': postData,
        };
      }));

      return enrichedNotifications;
    });
  }

}
