import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageUrlHelper {
  ImageUrlHelper._();

  static String resolve(String? path) {
    if (path == null || path.trim().isEmpty) {
      return '';
    }

    final trimmed = path.trim();

    // Full remote URL (MinIO storage or external CDN)
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final baseUrl = dotenv.env['BASE_URL'] ?? 'https://be-apple-store.eka-dev.cloud';

    if (trimmed.startsWith('/images/')) {
      return '$baseUrl$trimmed';
    } else if (trimmed.startsWith('/')) {
      return '$baseUrl/images$trimmed';
    } else {
      return '$baseUrl/images/$trimmed';
    }
  }
}
