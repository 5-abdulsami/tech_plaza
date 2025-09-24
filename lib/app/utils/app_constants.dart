class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://mqfsvfbluboixubxwtju.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1xZnN2ZmJsdWJvaXh1Ynh3dGp1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg2NDE0ODgsImV4cCI6MjA3NDIxNzQ4OH0.FGkPO9v_A2TtMuLqHw149qe_xpZTTESSYNF48QVDROw';

  // App Configuration
  static const String appName = 'TechPlaza';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String userKey = 'user_data';
  static const String tokenKey = 'auth_token';

  // Subscription Plans
  static const Map<String, int> subscriptionLimits = {
    'basic': 10,
    'standard': 30,
    'premium': -1, // unlimited
  };

  // Image Configuration
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // Chat Configuration
  static const int maxMessageLength = 500;
  static const Duration typingIndicatorTimeout = Duration(seconds: 3);
}
