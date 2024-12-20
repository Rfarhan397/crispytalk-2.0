import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crispy/model/res/components/app_back_button.dart';
import 'package:crispy/model/res/constant/app_utils.dart';
import 'package:crispy/provider/cloudinary/cloudinary_provider.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../constant.dart';
import '../../../model/res/constant/app_assets.dart';
import '../../../model/res/constant/app_icons.dart';
import '../../../model/res/widgets/app_text.dart.dart';
import '../../../model/res/widgets/app_text_field.dart';
import '../../../model/res/widgets/button_widget.dart';
import '../../../model/user_model/user_model.dart';
import '../../../provider/action/action_provider.dart';
import '../../../provider/profile/profileProvider.dart';
import '../../../provider/stream/streamProvider.dart';
import '../../../provider/user_provider/user_provider.dart';
import '../chatListScreen/groupChat.dart';

class CreateGroup extends StatefulWidget {
  CreateGroup({super.key});

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider2>(context); // Access UserProvider
    final profile = Provider.of<ProfileProvider>(context); // Access UserProvider
    final cloud = Provider.of<CloudinaryProvider>(context); // Access UserProvider
    final menuProvider =
    Provider.of<ActionProvider>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed:  profile.isLoading ? null:
            () async {
          createGroupChat(context, provider, _groupNameController, profile,cloud);
        },
        backgroundColor: Colors.transparent,
        splashColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.transparent,
        child: profile.isLoading ?
        const CircularProgressIndicator(color: primaryColor,)
            : SvgPicture.asset(AppIcons.next),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 2.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const AppBackButton(),
                  SizedBox(
                    width: 2.h,
                  ),
                  Container(
                    height: 50,
                    width: 75.w,
                    decoration: BoxDecoration(
                        color: const Color(0xffD9D9D9),
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            hasPrefixIcon: false,
                            focusBdColor: Colors.transparent,
                            controller: _groupNameController,
                            hintText: "Type the Group Name",
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              _groupNameController.clear();
                            },
                            child: SvgPicture.asset(AppIcons.close),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 1.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Consumer<ProfileProvider>(
                            builder: (context, value, child) {
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _showImagePicker(context,value);
                                    },
                                    child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(50),
                                            color: customGrey,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(50),
                                            child: value.profileImage != null
                                                ? Image.file(value.profileImage!, fit: BoxFit.cover, width: 100.w)
                                                : Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: SvgPicture.asset(
                                                AppIcons.camera,
                                                color: Colors.black12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(right: 1.w),
                                          padding: const EdgeInsets.all(5),
                                          decoration: const BoxDecoration(
                                            color: primaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          const AppTextWidget(
                            text: 'Select Photo',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    const AppTextWidget(
                      text: 'Select Members',
                      color: primaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                  ],
                ),
              ),
              // Search Bar
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 95.w,
                    decoration: const BoxDecoration(
                        color: Color(0xffD9D9D9),
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(18),
                            topRight: Radius.circular(18))),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: SvgPicture.asset(AppIcons.search),
                        ),
                        Expanded(
                          child: AppTextField(
                            focusBdColor: Colors.transparent,
                            controller: _searchController,
                            onChanged: (value) {
                              provider.searchUsers(value); // Trigger search
                            },
                            hintText: "Search",
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              provider.searchUsers(
                                  ''); // Reset search when clear is clicked
                            },
                            child: SvgPicture.asset(AppIcons.close),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // User List
              StreamBuilder<List<UserModelT>>(
                stream: StreamDataProvider().getFollowingUsers(currentUser),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: AppTextWidget(
                        text: 'Error: ${snapshot.error}',
                        fontSize: 16,
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: AppTextWidget(
                        text: 'No Friends found',
                        fontSize: 16,
                      ),
                    );
                  }

                  List<UserModelT> users = snapshot.data!;
                  print(
                      'Fetched users: $users'); // Add this to see the fetched data

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      UserModelT dUser = users[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: dUser.profileUrl.isNotEmpty
                                ? NetworkImage(dUser.profileUrl)
                                : const AssetImage(AppAssets.noProfile)
                            as ImageProvider,
                          ),
                          title: AppTextWidget(
                            text: dUser.name.toString(),
                            fontSize: 16.sp,
                            textAlign: TextAlign.start,
                            fontWeight: FontWeight.w500,
                          ),
                          subtitle: AppTextWidget(
                            text:
                            dUser.bio.isEmpty ? "User bio here" : dUser.bio,
                            fontSize: 12.sp,
                            textAlign: TextAlign.start,
                            fontWeight: FontWeight.w300,
                          ),
                          trailing: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const AppTextWidget(
                                  text: '01:33 PM', // Placeholder for time
                                  fontSize: 10,
                                  textAlign: TextAlign.start,
                                ),
                                SizedBox(height: 1.h),
                                UserSelectionCheckbox(
                                    dUser: dUser,
                                    selectedUsers: provider.selectedUsers),
                              ],
                            ),
                          ),
                          // Add Checkbox for selection
                        ),
                      );
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
  Future<void> createGroupChat(BuildContext context,
      UserProvider2 provider,
      TextEditingController groupNameController,
      ProfileProvider profile,
      CloudinaryProvider cloud
      ) async {
    // Check if users are selected
    if (provider.selectedUsers.isEmpty) {
      AppUtils().showToast(text: 'Please select at least one user to create a group',bgColor:  Colors.red);
      return;
    }

    // Check if the group name is empty
    if (groupNameController.text.trim().isEmpty) {
      AppUtils().showToast(text: 'Please enter a group name.',bgColor:  Colors.red);
      return;
    }

    // Check if group image is selected
    if (profile.profileImage == null) {
      AppUtils().showToast(text: 'Please select a group image.',bgColor:  Colors.red);
      return;
    }

    try {
      // Upload the group image to Cloud
      String? imageUrl = await cloud.uploadFile(profile.profileImage!);

      if (imageUrl == null) {
        AppUtils().showToast(text: 'Failed to upload the group image.', bgColor:Colors.red);
        return;
      }

      // Create a new group chat in Firestore
      DocumentReference groupRef = FirebaseFirestore.instance.collection('groupChats').doc();
      await groupRef.set({
        'groupName': groupNameController.text.trim(),
        'groupImage': imageUrl,
        'groupId': groupRef.id,
        'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
        'admin': currentUser,
        'members': [
          ...provider.selectedUsers.map((user) => user.userUid).toList(),
          currentUser
        ],
      });

      // Navigate to the Group Chat Screen
      Get.to(GroupChatScreen(
        groupName: groupNameController.text.trim(),
        groupImage: imageUrl,
        groupID: groupRef.id,
      ));

      // Show success message
      AppUtils().showToast(text: 'Group created successfully!',bgColor:  Colors.green);
      print('Group saved to Firebase successfully.');
    } catch (e) {
      AppUtils().showToast(text: 'Failed to save group members to Firebase: $e',bgColor:  Colors.red);

      // Reset the form fields
      provider.selectedUsers.clear();
      provider.selectedImage = null;
      groupNameController.clear();
    }
  }


  void _showImagePicker(BuildContext context, ProfileProvider provider) {
    Get.bottomSheet(
      Container(
        width: 100.w,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ButtonWidget(
              height: 5.h,
              width: 40.w,
              fontWeight: FontWeight.w400,
              text: "Gallery",
              onClicked: provider.pickProfileImage,
            ),
            const SizedBox(height: 20),
            ButtonWidget(
              height: 5.h,
              width: 40.w,
              fontWeight: FontWeight.w400,
              text: "Camera",
              onClicked: provider.pickProfileImageFromCamera,
            ),
          ],
        ),
      ),
    );
  }
}

PopupMenuItem<String> buildMenuItem(
    BuildContext context, String value, ActionProvider menuProvider) {
  return PopupMenuItem<String>(
    value: value,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: menuProvider.selectedItem == value
            ? const Color(0xffEDFE19)
            : Colors.transparent,
      ),
      child: Text(
        value,
        style: TextStyle(
          color: menuProvider.selectedItem == value
              ? Colors.black
              : Colors.white,
        ),
      ),
    ),
  );
}

class CustomCheckbox extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;

  const CustomCheckbox({
    super.key,
    required this.isChecked,
    required this.onChanged,
    this.activeColor = primaryColor,
    this.inactiveColor = primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!isChecked); // Toggle the checked state
      },
      child: Container(
        width: 20,
        height: 15,
        decoration: BoxDecoration(
          color: isChecked ? activeColor : Colors.transparent,
          border: Border.all(
            color: isChecked ? activeColor : inactiveColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: isChecked
            ? const Icon(
          Icons.check,
          size: 16,
          color: Colors.white,
        )
            : null, // Show checkmark only if checked
      ),
    );
  }
}

class UserSelectionCheckbox extends StatefulWidget {
  final UserModelT dUser;
  final List<UserModelT> selectedUsers;

  UserSelectionCheckbox({required this.dUser, required this.selectedUsers});

  @override
  State<UserSelectionCheckbox> createState() => _UserSelectionCheckboxState();
}

class _UserSelectionCheckboxState extends State<UserSelectionCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: widget.selectedUsers.contains(widget.dUser),
      onChanged: (bool? newValue) {
        setState(() {
          if (newValue == true) {
            // Add user to selectedUsers if checked
            widget.selectedUsers.add(widget.dUser);
          } else {
            // Remove user from selectedUsers if unchecked
            widget.selectedUsers.remove(widget.dUser);
          }
        });
      },
      activeColor: primaryColor,
      // Customize the selected color
      checkColor: Colors.white, // Customize the checkmark color
    );
  }
}