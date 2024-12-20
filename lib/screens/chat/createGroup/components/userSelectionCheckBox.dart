import 'package:flutter/material.dart';

import '../../../../constant.dart';
import '../../../../model/user_model/user_model.dart';

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
