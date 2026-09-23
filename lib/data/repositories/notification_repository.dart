import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/local_storage.dart';
import '../../core/utils/app_logger.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiClient _api = ApiClient.instance;
  final LocalStorageService _storage;

  NotificationRepository(this._storage);

  bool get isAuthenticated => _storage.hasToken;

  Future<NotificationListResponse> getNotifications({int page = 1, int limit = 30}) async {
    if (!isAuthenticated) {
      return const NotificationListResponse(notifications: [], unreadCount: 0);
    }

    final response = await _api.get(
      ApiEndpoints.notifications,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final data = response.data?['data'] ?? response.data ?? {};
    return NotificationListResponse.fromJson(Map<String, dynamic>.from(data));
  }

  Future<NotificationModel?> markAsRead(String id) async {
    if (!isAuthenticated || id.isEmpty) return null;

    try {
      final response = await _api.patch(ApiEndpoints.markNotificationRead(id));
      final data = response.data?['data'] ?? response.data;
      if (data is Map) {
        return NotificationModel.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      AppLogger.w('Failed to mark notification $id as read: $e', 'NOTIFICATION');
    }
    return null;
  }

  Future<bool> markAllAsRead() async {
    if (!isAuthenticated) return false;

    try {
      final response = await _api.patch(ApiEndpoints.markAllNotificationsRead);
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.w('Failed to mark all notifications as read: $e', 'NOTIFICATION');
      return false;
    }
  }

  Future<bool> registerDevice({
    required String fcmToken,
    required String platform,
  }) async {
    if (!isAuthenticated || fcmToken.isEmpty) return false;

    try {
      final response = await _api.post(
        ApiEndpoints.registerDevice,
        data: {
          'platform': platform,
          'fcmToken': fcmToken,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.w('Failed to register device for push: $e', 'FCM');
      return false;
    }
  }
}
