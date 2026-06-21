/// Application-wide constants for Next Home
class AppConstants {
  AppConstants._();

  // ── API ───────────────────────────────────────────────────────────────────
  static const String apiBaseUrl      = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://10.0.2.2:3000/api/v1');  // 10.0.2.2 = localhost from Android emulator
  static const String socketUrl       = String.fromEnvironment('SOCKET_URL',
      defaultValue: 'http://10.0.2.2:3001');
  static const String googleMapsKey   = String.fromEnvironment('GOOGLE_MAPS_API_KEY',
      defaultValue: 'AIzaSyBSU4LGpOsZu7KdPQ-b9e1Vg4u2ij9fquI');

  // ── Hive Box Names ────────────────────────────────────────────────────────
  static const String userBox         = 'user_box';
  static const String propertyBox     = 'property_box';
  static const String settingsBox     = 'settings_box';

  // ── Shared Pref Keys ─────────────────────────────────────────────────────
  static const String prefThemeMode   = 'theme_mode';
  static const String prefLanguage    = 'language';

  // ── Pagination ────────────────────────────────────────────────────────────
  static const int pageSize           = 20;

  // ── Property ──────────────────────────────────────────────────────────────
  static const List<String> propertyTypes = [
    'apartment', 'house', 'villa', 'studio', 'commercial'
  ];
  static const List<String> furnishedStatus = [
    'furnished', 'semi-furnished', 'unfurnished'
  ];

  // ── Map ───────────────────────────────────────────────────────────────────
  static const double defaultLat      = 28.6139;  // New Delhi
  static const double defaultLng      = 77.2090;
  static const double defaultMapZoom  = 12.0;
  static const double searchRadiusKm  = 5.0;

  // ── Payment ───────────────────────────────────────────────────────────────
  static const String razorpayKeyId   = String.fromEnvironment('RAZORPAY_KEY_ID', defaultValue: '');
  static const String stripePublishKey = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY', defaultValue: '');
}
