import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavController extends GetxController {
  RxInt selectedIndex = 0.obs;
  bool get isAuth => FirebaseAuth.instance.currentUser != null;

  final PageController pageController = PageController();

  void changeTabIndexWithAnimation(int index) {
    selectedIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void onPageChanged(int index) {
    selectedIndex.value = index;
  }
}
