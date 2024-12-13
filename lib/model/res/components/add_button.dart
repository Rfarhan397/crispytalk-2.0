import 'package:flutter/material.dart';

import '../../../constant.dart';
import '../widgets/app_text.dart.dart';

class AddButton extends StatelessWidget {
  const AddButton({super.key, required this.text});
  final text;

  @override
  Widget build(BuildContext context) {
    return   Row(
      children: [
        Container(
          height: 25,
          width: 25,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: primaryColor,
          ),
          child: const Icon(
            Icons.add,
            size: 18,
            color: Colors.white,
          ),
        )  ,
        SizedBox(width: 5,),
        AppTextWidget(text: text,fontSize: 14,color: Colors.black,)
      ],
    );
  }
}
