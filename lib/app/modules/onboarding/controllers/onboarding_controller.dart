import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends GetxController {
  final List<String> images = [
    'assets/images/home-template.jpeg',
    'assets/images/home-template.jpeg',
    'assets/images/home-template.jpeg',
  ];
  final pageController = PageController().obs;

  Future<void> completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
  }
}
