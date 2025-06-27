import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() => runApp(const MediBestiApp());

class MediBestiApp extends StatelessWidget {
  const MediBestiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediBesti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'PTSans',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
