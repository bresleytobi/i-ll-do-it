/// Application Configuration
class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // API Configuration
  static const String apiBaseUrl = 'YOUR_API_BASE_URL';
  static const Duration apiTimeout = Duration(seconds: 30);

  // App Configuration
  static const String appName = 'I\'ll Do It';
  static const String appVersion = '1.0.0';
  static const String organisationId = 'com.illdo';

  // Feature Flags
  static const bool enableDebugMode = true;
  static const bool enableAnalytics = false;
}
