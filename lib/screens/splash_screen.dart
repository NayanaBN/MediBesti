import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'upload_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<Widget> _getNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seenOnboarding') ?? false;
    return seen ? const UploadScreen() : const OnboardingScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getNextScreen(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        return AnimatedSplashScreen(
          splash: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(height: 100),
                Image(
                  image: AssetImage("lib/assets/onboarding/logo.png"),
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          backgroundColor: Colors.deepPurple.shade50,
          duration: 2000,
          splashTransition: SplashTransition.fadeTransition,
          pageTransitionType: PageTransitionType.bottomToTop,
          nextScreen: snapshot.data!,
        );
      },
    );
  }
}
