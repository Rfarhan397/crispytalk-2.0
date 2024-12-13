import 'package:flutter/material.dart';

import '../../anum/user_type.dart';
import '../../constant.dart';
import '../../model/mediaPost/mediaPost_model.dart';

class OtherUSerDataProvider with ChangeNotifier {

  MediaPost? _mediaPost;
  UserType? _userType;



  MediaPost? get mediaPost => _mediaPost;
  UserType? get userType => _userType;

  void setMediaPost( mediaPost, UserType? userType) {
    _mediaPost = mediaPost;
    _userType = userType;
    notifyListeners();
  }
  // void initializeListener(String userUid) {
  //   fireStore.collection('users').doc(userUid).snapshots().listen((snapshot) {
  //     if (snapshot.exists) {
  //       _mediaPost?.userDetails?.followers =
  //       List<String>.from(snapshot.data()?['follow'] ?? []);
  //       notifyListeners();
  //     }
  //   });
  // }

}