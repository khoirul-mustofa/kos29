import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'themeMode';

  ThemeMode get theme {
    final bool? isDark = _box.read(_key);
    return isDark == true ? ThemeMode.dark : ThemeMode.light;
  }

  void saveThemeToBox(bool isDark) {
    _box.write(_key, isDark);
  }

  void toggleTheme() {
    final currentTheme = theme;
    final newTheme =
        currentTheme == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    saveThemeToBox(newTheme == ThemeMode.dark);

    Get.changeThemeMode(newTheme);
    update();
  }
}
