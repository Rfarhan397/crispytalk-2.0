import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../model/res/constant/app_icons.dart';
import '../../../model/res/routes/routes_name.dart';
import '../../../model/res/widgets/app_text_field.dart';
import '../../../provider/user_provider/user_provider.dart';

class SearchChat extends StatelessWidget {
   SearchChat({super.key});
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);

    return   Padding(
      padding:  EdgeInsets.only(top: 2.h),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 85.w,
            decoration: const BoxDecoration(
                color: Color(0xffD9D9D9),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(18),
                    topRight: Radius.circular(18)
                )
            ),
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
                      provider.searchUsers(value);
                    },
                    hintText: "Search",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      provider.searchUsers('');
                    },
                    child: SvgPicture.asset(AppIcons.close),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 2.w),
            child: GestureDetector(
                onTap: () {Get.toNamed(RoutesName.createGroup);
                },
                child: SvgPicture.asset(AppIcons.createGroup)),
          )

        ],
      ),
    );
  }
}
