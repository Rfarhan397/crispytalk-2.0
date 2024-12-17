import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/res/constant/app_assets.dart';
import '../../model/user_model/user_model.dart';

class UserProvider with ChangeNotifier {
  List<UserModel> _users = [
    UserModel(
        id: '1',
        username: 'Alex',
        nickname: 'alex456',
        imageUrl: AppAssets.lady,
        followers: 106,
        isFollowing: true,
        message: "WOW! this video is very cool"
    ),
    UserModel(
        id: '2',
        username: 'Sania',
        nickname: 'Sania678',
        imageUrl: AppAssets.boy,
        followers: 100,
        isFollowing: false,
        message: "Hey are you! why you can’t pick my call?"
    ),
    UserModel(
        id: '3',
        username: 'Shoaib',
        nickname: 'Shabi234',
        imageUrl: AppAssets.boy,
        followers: 2500000,
        isFollowing: true,
        message: "Hey are you! why you can’t pick my call?"

    ),
  ];
  void toggleSelection(UserModel user) {
    if (_selectedUsers.contains(user)) {
      _selectedUsers.remove(user);
    } else {
      _selectedUsers.add(user);
    }
    notifyListeners();
  }

  bool isSelected(UserModel user) {
    return _selectedUsers.contains(user);
  }

  List<UserModel> get users => _users;

  void toggleFollowStatus(UserModel user) {
    user.isFollowing = !user.isFollowing;
    notifyListeners();
  }




  ////search in chat///////



  List<UserModel> _filteredUsers = [];
  UserProvider() {
    _filteredUsers = _users; // Initially, show all users
  }

  List<UserModel> get chatUsers => _filteredUsers;

  // Search method to filter the users
  void searchUsers(String query) {
    if (query.isEmpty) {
      _filteredUsers = _users;
    } else {
      _filteredUsers = _users
          .where((user) => user.username.toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void setUsers(List<UserModel> users) {
    _users = users;
    _filteredUsers = _users;
    notifyListeners();
  }




//////////to select the friends to create a new group/////

  final List<UserModel> _selectedUsers = [];
  // Toggle checkbox and update selected users list
  void toggleCheckbox(int index, bool isChecked) {
    chatUsers[index].isChecked = isChecked;

    if (isChecked) {
      _selectedUsers.add(chatUsers[index]);
    } else {
      _selectedUsers.removeWhere((user) => user.id == chatUsers[index].id);
    }

    notifyListeners(); // Notify listeners to update UI
  }

  List<UserModel> get selectedUsers => _selectedUsers; // Return selected users





///////to remove the selectedUsers///////////
  void removeUser(UserModelT user) {
    user.isChecked = false; // Uncheck the user's selection
    _selectedUsers.removeWhere((selectedUser) => selectedUser.id == user.userUid); // Remove from selected list
    notifyListeners(); // Notify the UI to update
  }



}


class UserProvider2 with ChangeNotifier {
  List<UserModelT> selectedUsers = [];

  void toggleSelection(UserModelT user) {
      if (selectedUsers.contains(user)) {
        selectedUsers.remove(user);
      } else {
        selectedUsers.add(user);
      }
  }
  late final String urlGroupImage;

  Future<String?> uploadImageAndGetLink(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance.ref('GroupImages/$fileName');
      await storageRef.putFile(imageFile);
      String downloadURL = await storageRef.getDownloadURL();
      print("Image uploaded successfully: $downloadURL");
      return downloadURL;

    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }
  File? selectedImage; // To store the selected image
  final ImagePicker picker = ImagePicker();
  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Compress the image for optimization
      );

      if (pickedFile != null) {
          selectedImage = File(pickedFile.path);
          selectedUsers.clear();
          notifyListeners();
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  List<UserModelT> _filteredUsers = [];
  final List<UserModelT> _selectedUsers = [];
  List<UserModelT> get chatUsers => _filteredUsers;
  List<UserModelT> users = [];
  void toggleCheckbox(int index, bool isChecked) {
    chatUsers[index].isChecked = isChecked;

    if (isChecked) {
      _selectedUsers.add(chatUsers[index]);
    } else {
      _selectedUsers.removeWhere((user) => user.userUid== chatUsers[index].userUid);
    }

    notifyListeners(); // Notify listeners to update UI
  }

  // Return the list of filtered users (either all or based on search)
  List<UserModelT> get filteredUsers => _filteredUsers;

  // Return the list of all selected users

  // This method is used to check if a user is selected
  bool isSelected(UserModelT user) {
    return _selectedUsers.contains(user);
  }
  void removeUser(UserModelT user) {
    selectedUsers.remove(user);
    notifyListeners(); // Notify listeners to rebuild UI
  }

  // Update the filtered list based on the search query
  void searchUsers(String query) {
    if (query.isEmpty) {
      _filteredUsers = users;
    } else {
      _filteredUsers = users
          .where((user) => user.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // Toggle the selection of a user


  // Set the list of all users (this would typically be fetched from a database or API)
  void setUsers(List<UserModelT> users) {
    users = users;
    _filteredUsers = users; // Initially show all users
    notifyListeners();
  }

  // Helper to check if a specific index is selected
  bool isIndexSelected(int index) {
    return _selectedUsers.contains(_filteredUsers[index]);
  }

  // Toggle the selection of a user based on index
  void toggleSelectionByIndex(int index) {
    final user = _filteredUsers[index];
    if (_selectedUsers.contains(user)) {
      _selectedUsers.remove(user); // Remove if already selected
    } else {
      _selectedUsers.add(user); // Add if not selected
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedUsers.clear();
    notifyListeners();
  }
}


class SearchProvider extends ChangeNotifier {
  List<UserModelT> _allUsers = []; // List to store all users fetched initially
  List<UserModelT> _filteredUsers = []; // Filtered users based on search query
  bool _isLoading = true; // To track loading state

  List<UserModelT> get filteredUsers => _filteredUsers;
  bool get isLoading => _isLoading;

  // Fetch all users from Firestore
  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      _allUsers = snapshot.docs.map((doc) => UserModelT.fromMap(doc.data())).toList();
      _filteredUsers = _allUsers; // Initially, show all users
    } catch (e) {
      debugPrint('Error fetching users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update filtered users based on the search query
  void searchUsers(String query) {
    if (query.isEmpty) {
      _filteredUsers = _allUsers; // Reset to all users when query is empty
    } else {
      _filteredUsers = _allUsers.where((user) {
        final nameLower = user.name.toLowerCase();
        final queryLower = query.toLowerCase();
        return nameLower.contains(queryLower);
      }).toList();
    }
    notifyListeners();
  }
}
