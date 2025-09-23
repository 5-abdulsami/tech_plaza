class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

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
