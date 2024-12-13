import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sizer/sizer.dart';
import '../../../constant.dart';
import '../../../model/res/constant/app_assets.dart';
import '../../../model/res/constant/app_colors.dart';
import '../../../model/res/routes/routes_name.dart';
import '../../../model/res/widgets/app_text.dart.dart';
import '../../login/loginScreen.dart';

class OnBoardingScreenOne extends StatefulWidget {
  const OnBoardingScreenOne({super.key});

  @override
  _OnBoardingScreenOneState createState() => _OnBoardingScreenOneState();
}

class _OnBoardingScreenOneState extends State<OnBoardingScreenOne> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // List of onboarding data (image, title, description)
  final List<Map<String, String>> onboardingData = [
    {
      "image": AppAssets.onBoardingOne,
      "title": "Welcome to Crispytalk!",
      "description":
      "Discover a world where conversations and entertainment blend seamlessly! "
          "Crispytalk lets you chat, create, and share short video clips in real-time."
    },
    {
      "image": AppAssets.onBoardingTwo,
      "title": "Create, Share & Connect",
      "description":
    "Express yourself through short, engaging videos. Build your community, follow your favorite creators, and stay updated with the latest trends."    },
    {
      "image": AppAssets.onBoardingTwo,
      "title": "Stay Connected & Connect",
      "description":
    "Express yourself through short, engaging videos. Build your community, follow your favorite creators, and stay updated with the latest trends.   "
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _pageController,
        itemCount: onboardingData.length,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image and title will change based on the page index
              Image.asset(
                onboardingData[index]["image"]!,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 3.h),
              AppTextWidget(
                text: onboardingData[index]["title"]!,
                fontWeight: FontWeight.w700,
                fontSize: 40,
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: AppTextWidget(
                  text: onboardingData[index]["description"]!,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey,
                  fontSize: 15,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingData.length,
                      (dotIndex) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 0.6.w),
                      width: _currentPage == dotIndex ? 10.w : 4.w,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: _currentPage == dotIndex
                            ? primaryColor
                            : Color(0xffB1ACAC),
                      ),
                    );
                  },
                ),
              ),
              Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 5.w),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(LoginScreen());
                      // Get.offAllNamed(RoutesName.loginScreen);
                      // Handle skip logic here (e.g., navigate to the next screen)
                    },
                    child: AppTextWidget(
                      text: 'Skip',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
            ],
          );
        },
      ),
    );
  }
}
