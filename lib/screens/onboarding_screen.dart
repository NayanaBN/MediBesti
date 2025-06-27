import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'upload_screen.dart';
import 'package:flutter/material.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      'image': 'lib/assets/onboarding/scan.png',
      'title': 'Scan Prescriptions',
      'subtitle': 'Easily scan and upload your medical prescriptions.',
    },
    {
      'image': 'lib/assets/onboarding/allergy.png',
      'title': 'Allergy Alerts',
      'subtitle': 'Get warnings if medicines match your allergies.',
    },
    {
      'image': 'lib/assets/onboarding/notifications.png',
      'title': 'Smart Reminders',
      'subtitle': 'Never miss a dose with smart notification reminders.',
    },
  ];

  void _finishOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    Navigator.pushReplacementNamed(context, '/upload');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _pages.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  _pages[index]['image']!,
                  height: 250,
                ),
                const SizedBox(height: 40),
                Text(
                  _pages[index]['title']!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _pages[index]['subtitle']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
      bottomSheet: _currentIndex == _pages.length - 1
          ?
      ElevatedButton(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('seenOnboarding', true);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UploadScreen()),
          );
        },
        child: const Text("Get Started"),
      )

          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _finishOnboarding,
            child: const Text('Skip'),
          ),
          TextButton(
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
