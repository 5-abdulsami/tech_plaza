import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';

class LanguageController extends GetxController {
  final Rx<Locale> _currentLocale = const Locale('en', 'US').obs;

  Locale get currentLocale => _currentLocale.value;
  Rx<Locale> get currentLocaleRx => _currentLocale;

  bool get isUrdu => _currentLocale.value.languageCode == 'ur';

  @override
  void onInit() {
    super.onInit();
    _loadLanguageFromStorage();
  }

  Future<void> _loadLanguageFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(AppConstants.languageKey) ?? 'en';
      _currentLocale.value = languageCode == 'ur'
          ? const Locale('ur', 'PK')
          : const Locale('en', 'US');
    } catch (e) {
      _currentLocale.value = const Locale('en', 'US');
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    try {
      final locale = languageCode == 'ur'
          ? const Locale('ur', 'PK')
          : const Locale('en', 'US');

      _currentLocale.value = locale;
      Get.updateLocale(locale);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.languageKey, languageCode);
    } catch (e) {
      // Handle error
    }
  }

  void toggleLanguage() {
    final newLanguage = isUrdu ? 'en' : 'ur';
    changeLanguage(newLanguage);
  }
}
