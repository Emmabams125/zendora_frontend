/// Single source of truth for the backend location. This is the only place
/// that needs to change when switching between local dev (emulator alias or
/// LAN IP) and the live Vercel deployment.
class AppConfig {
  AppConfig._();

  static const String baseUrl = 'https://zendora-backend.vercel.app';
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
