import 'package:crispy/constant.dart';
import 'package:crispy/main.dart';
import 'package:crispy/model/res/components/app_back_button.dart';
import 'package:crispy/model/res/widgets/app_text.dart.dart';
import 'package:crispy/model/res/widgets/cachedImage/cachedImage.dart';
import 'package:crispy/model/res/widgets/customDialog.dart';
import 'package:crispy/provider/current_user/current_user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../model/res/constant/app_assets.dart';
import '../../../../model/user_model/user_model.dart';
import '../../../../provider/stream/streamProvider.dart';
import '../../../../model/res/constant/app_utils.dart';
import '../../createGroup/createGroup.dart';
import 'editNameAndPhoto.dart';

class EditGroupDetailsScreen extends StatefulWidget {
  const EditGroupDetailsScreen({super.key});

  @override
  State<EditGroupDetailsScreen> createState() => _EditGroupDetailsScreenState();
}

class _EditGroupDetailsScreenState extends State<EditGroupDetailsScreen> {
  List<dynamic> membersList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMembers();
  }

  Future<void> loadMembers() async {
    var user = Get.arguments;
    final members = await StreamDataProvider().getGroupMembers(user['groupID']);
    setState(() {
      membersList = members;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = Get.arguments;
    final currentUser = Provider.of<CurrentUserProvider>(context, listen: false).currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const AppBackButton(),
        actions: [
          if (currentUser?.userUid == user['admin'])
            GestureDetector(
              onTap: () {
                Get.to(EditNameAndPhoto(
                  groupName: user['groupName'],
                  groupPhoto: user['groupImage'],
                  groupID: user['groupID'],
                  admin: user['admin'],
                ));
              },
              child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: AppTextWidget(
                        text: 'Edit',
                        color: primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        textDecoration: TextDecoration.underline,
                        underlinecolor: primaryColor,
                      ),
                    )
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CachedShimmerImageWidget(
                            imageUrl: user['groupImage'])),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  AppTextWidget(
                    text: user['groupName'],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            SizedBox(
              height: 1.h,
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: primaryColor,
                    ))
                  : Column(
                      children: [
                        SizedBox(
                          height: 3.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppTextWidget(
                                text: '${membersList.length} Members',
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: primaryColor,
                              ),
                              if (currentUser?.userUid == user['admin'])
                                IconButton(
                                      onPressed: () => showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) => Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.75,
                                          padding: const EdgeInsets.all(20),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(20)),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const AppTextWidget(
                                                text: 'Add Members',
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              const SizedBox(height: 20),
                                              StreamBuilder<List<UserModelT>>(
                                                stream: StreamDataProvider()
                                                    .getFollowingUsers(
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Center(
                                                      child: AppTextWidget(
                                                        text:
                                                            'Error: ${snapshot.error}',
                                                        fontSize: 16,
                                                      ),
                                                    );
                                                  } else if (!snapshot
                                                          .hasData ||
                                                      snapshot.data!.isEmpty) {
                                                    return const Center(
                                                      child: AppTextWidget(
                                                        text:
                                                            'No Friends found',
                                                        fontSize: 16,
                                                      ),
                                                    );
                                                  }

                                                  List<UserModelT> users =
                                                      snapshot.data!;
                                                  // Filter out users who are already members
                                                  users = users
                                                      .where((u) => !membersList
                                                          .any((m) =>
                                                              m.userUid ==
                                                              u.userUid))
                                                      .toList();

                                                  if (users.isEmpty) {
                                                    return const Center(
                                                      child: AppTextWidget(
                                                        text:
                                                            'All friends are already in group',
                                                        fontSize: 16,
                                                      ),
                                                    );
                                                  }

                                                  return Expanded(
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: users.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        UserModelT dUser =
                                                            users[index];
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical:
                                                                      4.0),
                                                          child: ListTile(
                                                            leading:
                                                                CircleAvatar(
                                                              radius: 25,
                                                              child: CachedShimmerImageWidget(
                                                                  imageUrl: dUser
                                                                      .profileUrl),
                                                            ),
                                                            title:
                                                                AppTextWidget(
                                                              text: dUser.name
                                                                  .toString(),
                                                              fontSize: 16.sp,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            subtitle:
                                                                AppTextWidget(
                                                              text: dUser.bio
                                                                      .isEmpty
                                                                  ? "User bio here"
                                                                  : dUser.bio,
                                                              fontSize: 12.sp,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                            ),
                                                            trailing:
                                                                IconButton(
                                                              icon: const Icon(
                                                                  Icons
                                                                      .add_circle_outline,
                                                                  color:
                                                                      primaryColor),
                                                              onPressed: () =>
                                                                  _addMemberToGroup(
                                                                      user[
                                                                          'groupID'],
                                                                      dUser
                                                                          .userUid!),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(Icons.group_add_outlined,
                                          color: primaryColor, size: 28),
                                    )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: membersList.length,
                          itemBuilder: (context, index) {
                            final member = membersList[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: CachedShimmerImageWidget(
                                        imageUrl: member.profileUrl ?? '',
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: AppTextWidget(
                                      text: member.name ?? 'Unknown',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  if (currentUser?.userUid != member.userUid &&  currentUser?.userUid == user['admin'])
                                    IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.red),
                                      onPressed: () {
                                        MyCustomDialog.show(
                                          showTitle: true,
                                          title: 'Remove Member',
                                          yes: 'Remove',
                                          cancel: 'Cancel',
                                          hintText:
                                              'Are you sure you want to remove ${member.name}?',
                                          cancelTap: () {
                                            Navigator.pop(context);
                                          },
                                          yesTap: () {
                                            Navigator.pop(context);
                                            _removeMember(user['groupID'],
                                                member.userUid!, context);
                                          },
                                        );
                                      },
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addMemberToGroup(String groupId, String memberId) async {
    try {
      await FirebaseFirestore.instance
          .collection('groupChats')
          .doc(groupId)
          .update({
        'members': FieldValue.arrayUnion([memberId])
      });

      loadMembers(); // Refresh member list
      AppUtils().showToast(text: 'Member added successfully');
      Get.back();
    } catch (e) {
      AppUtils().showToast(text: 'Failed to add member');
    }
  }

  Future<void> _removeMember(
      String groupId, String memberId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('groupChats')
          .doc(groupId)
          .update({
        'members': FieldValue.arrayRemove([memberId])
      });

      setState(() {
        membersList.removeWhere((member) => member.userUid == memberId);
      });

      AppUtils().showToast(text: 'Member removed successfully');
    } catch (e) {
      AppUtils().showToast(text: 'Failed to remove member');
    }
  }
}
