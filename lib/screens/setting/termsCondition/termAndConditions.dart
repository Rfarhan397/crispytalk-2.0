import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../constant.dart';
import '../../../model/res/components/app_back_button.dart';
import '../../../model/res/widgets/app_text.dart.dart';

class TermAndConditions extends StatelessWidget {
  const TermAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
        leading: const AppBackButton(),
        centerTitle: true,
        title: const AppTextWidget(text: 'Term and Conditions',color: primaryColor,fontSize: 18,fontWeight: FontWeight.w700,),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 5.w,vertical: 2.h),
              child: AppTextWidget(text: 'At Crispytalk, we are committed to protecting your privacy and e'
                  'nsuring the security of your personal data. This Privacy Policy explains how we collect,'
                  ' use, and store your information when you use our app ("App"). By using Crispytalk,'
                  ' you consent to the practices described in this policy. We collect personal data such as your name,'
                  ' email address, phone number, and any other information you provide when you create an account. '
                  'Additionally, we may collect non-personal data such as your IP address, device information,'
                  ' and usage data. We use this information to provide, improve, '
                  'and personalize the App, as well as for analytics and security purposes. \n You agree to indemnify, '
                  'defend, and hold harmless Crispytalk and its affiliates, officers, and employees from any claim,'
                  ' demand, or damages, including legal fees, arising out of your use of the App or violation of these '
                  'Terms. Crisptalk reserves the right to suspend or terminate your access to the App at any time for'
                  ' any reason,'
                  ' including but not limited to violation of these Terms.',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                textAlign: TextAlign.start,
              ),
            )
          ],
        ),
      ),
    );
  }
}
