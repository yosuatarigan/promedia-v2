import 'package:flutter/material.dart';
import 'package:promedia_v2/onboarding.dart';
import 'dart:async';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Image.asset('assets/3.png', width: size.width * 0.6),
          ),
          Image.asset('assets/2.png', width: size.width * 0.8),
          Align(
            alignment: Alignment.centerLeft,
            child: Image.asset('assets/4.png', width: size.width * 0.8),
          ),
        ],
      ),
    );
  }
}