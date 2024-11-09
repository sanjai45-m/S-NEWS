import 'package:flutter/material.dart';
import 'package:SNEWS/custom_widget/get_started_page.dart';
import 'package:flutter_overboard/flutter_overboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingOverlay extends StatefulWidget {
  const OnBoardingOverlay({super.key});

  @override
  State<OnBoardingOverlay> createState() => _OnBoardingOverlayState();
}

class _OnBoardingOverlayState extends State<OnBoardingOverlay> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: OverBoard(
        allowScroll: true,
        pages: pages,
        showBullets: true,
        inactiveBulletColor: Colors.blue,
        // backgroundProvider: NetworkImage('https://picsum.photos/720/1280'),
        skipCallback: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Skip clicked"),
          ));
        },
        finishCallback: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool(
              'isFirstLaunch', false); // Set onboarding as complete

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const GetStartedPage(),
            ),
          );
        },
      ),
    );
  }
}

final pages = [
  PageModel(
      color: const Color(0xFF0282CB),
      imageAssetPath: 'assets/images/latestnews.png',
      title: 'Stay Informed',
      body: 'Get the latest news from around the world at your fingertips.',
      doAnimateImage: true),
  PageModel(
      color: const Color(0xFF5F8DAA),
      imageAssetPath: 'assets/images/ree.png',
      title: 'Regional News',
      body:
          'Read news in your preferred language and stay connected with local events.',
      doAnimateImage: true),
  PageModel(
      color: const Color(0xFFFF898B),
      imageAssetPath: 'assets/images/community.jpg',
      title: 'Community Chat',
      body: 'Join the conversation and discuss the latest news with others.',
      doAnimateImage: true),
];
