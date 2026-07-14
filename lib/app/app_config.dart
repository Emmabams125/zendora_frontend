/// Single source of truth for the backend location. When switching between
/// the Android emulator (10.0.2.2) and a physical device (your machine's
/// LAN IP), this is the only place that needs to change.
class AppConfig {
  AppConfig._();

  static const String apiHost = '192.168.0.85';
  static const int apiPort = 5000;

  static const String baseUrl = 'http://$apiHost:$apiPort';
  static const String apiBaseUrl = '$baseUrl/api';

  /// The backend returns media (avatars, etc.) as host-relative paths like
  /// `/uploads/avatars/x.jpg`. Image.network needs an absolute URI, so
  /// resolve it against [baseUrl] here rather than at every call site.
  static String? resolveMediaUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$baseUrl${path.startsWith('/') ? path : '/$path'}';
  }
}
