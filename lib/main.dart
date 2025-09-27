import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/controllers/chat_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/controllers/theme_controller.dart';
import 'app/controllers/language_controller.dart';
import 'app/controllers/auth_controller.dart';
import 'app/utils/app_theme.dart';
import 'app/utils/app_constants.dart';
import 'app/translations/app_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Initialize and get controllers
  Get.put(ThemeController());
  Get.put(LanguageController());
  final authController = Get.put(AuthController()); // Get the instance
  Get.put(ChatController());

  // Wait for AuthController to be ready
  await authController.initializeAuth();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const TechPlazaApp());
}

double screenWidth = Get.width;
double screenHeight = Get.height;

class TechPlazaApp extends StatelessWidget {
  const TechPlazaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final languageController = Get.find<LanguageController>();

    return Obx(
      () => GetMaterialApp(
        title: 'TechPlaza',
        debugShowCheckedModeBanner: false,

        // Theme
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode,

        // Localization
        locale: languageController.currentLocale,
        fallbackLocale: const Locale('en', 'US'),
        translations: AppTranslations(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', 'US'), Locale('ur', 'PK')],

        // Navigation
        initialRoute: AppRoutes.splash,
        getPages: AppPages.routes,

        // Default transition
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
