import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';

class ThemeController extends GetxController {
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;

  ThemeMode get themeMode => _themeMode.value;
  Rx<ThemeMode> get themeModeRx => _themeMode;

  bool get isDarkMode {
    if (_themeMode.value == ThemeMode.system) {
      return Get.isPlatformDarkMode;
    }
    return _themeMode.value == ThemeMode.dark;
  }

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
  }

  Future<void> _loadThemeFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(AppConstants.themeKey) ?? 0;
      _themeMode.value = ThemeMode.values[themeIndex];
    } catch (e) {
      _themeMode.value = ThemeMode.system;
    }
  }

  Future<void> changeTheme(ThemeMode themeMode) async {
    try {
      _themeMode.value = themeMode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.themeKey, themeMode.index);
      Get.changeThemeMode(themeMode);
    } catch (e) {
      // Handle error
    }
  }

  void toggleTheme() {
    final newTheme = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    changeTheme(newTheme);
  }
}
