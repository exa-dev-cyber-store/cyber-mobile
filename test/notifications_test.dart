import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyber/core/network/api_client.dart';
import 'package:cyber/core/storage/local_storage.dart';
import 'package:cyber/data/models/notification_model.dart';
import 'package:cyber/data/repositories/notification_repository.dart';
import 'package:cyber/app/modules/notifications/controllers/notifications_controller.dart';

class MockNotificationHttpAdapter implements HttpClientAdapter {
  int getCount = 0;
  int markReadCount = 0;
  int markAllCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.contains('/api/notifications/read-all')) {
      markAllCount++;
      return ResponseBody.fromString(
        jsonEncode({'success': true, 'message': 'All marked as read'}),
        200,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
      );
    }

    if (options.path.contains('/read')) {
      markReadCount++;
      final notifId = options.path.split('/')[3];
      return ResponseBody.fromString(
        jsonEncode({
          'success': true,
          'data': {
            '_id': notifId,
            'title': 'Updated Title',
            'body': 'Updated Body',
            'type': 'delivery',
            'isRead': true,
            'createdAt': DateTime.now().toIso8601String(),
          },
        }),
        200,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
      );
    }

    if (options.path.contains('/api/notifications')) {
      getCount++;
      final page = (options.queryParameters['page'] as num?)?.toInt() ?? 1;

      if (page == 2) {
        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'data': {
              'notifications': [
                {
                  '_id': 'notif-4',
                  'title': 'Order Delivered',
                  'body': 'Your package has been delivered',
                  'type': 'delivery',
                  'isRead': true,
                  'createdAt': '2026-09-17T10:00:00.000Z',
                },
              ],
              'unreadCount': 2,
              'pagination': {'total': 4, 'page': 2, 'limit': 20, 'totalPages': 2},
            },
          }),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      }

      return ResponseBody.fromString(
        jsonEncode({
          'success': true,
          'data': {
            'notifications': [
              {
                '_id': 'notif-1',
                'title': 'Package in transit',
                'body': 'Your order #ORD-123 is on the way',
                'type': 'delivery',
                'isRead': false,
                'createdAt': '2026-09-20T10:00:00.000Z',
                'data': {'orderId': 'ORD-123'},
              },
              {
                '_id': 'notif-2',
                'title': 'Flash Sale Voucher',
                'body': 'Get 15% off using code APPLE15',
                'type': 'voucher',
                'isRead': false,
                'createdAt': '2026-09-19T08:30:00.000Z',
                'data': {'voucherCode': 'APPLE15', 'discount': 15},
              },
              {
                '_id': 'notif-3',
                'title': 'New iPhone Available',
                'body': 'iPhone 17 Pro is now in stock',
                'type': 'promo',
                'isRead': true,
                'createdAt': '2026-09-18T12:00:00.000Z',
              },
            ],
            'unreadCount': 2,
            'pagination': {'total': 4, 'page': 1, 'limit': 20, 'totalPages': 2},
          },
        }),
        200,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
      );
    }

    return ResponseBody.fromString(
      jsonEncode({'success': true, 'data': {}}),
      200,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late MockNotificationHttpAdapter mockAdapter;
  late NotificationRepository repository;

  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({'token': 'test-auth-token'});
    storage = await LocalStorageService.getInstance();
    await storage.setToken('test-auth-token');

    mockAdapter = MockNotificationHttpAdapter();
    final apiClient = await ApiClient.initialize(storage);
    apiClient.dio.httpClientAdapter = mockAdapter;

    repository = NotificationRepository(storage);
  });

  group('NotificationModel Tests', () {
    test('Correctly parses notification JSON with all fields & helpers', () {
      final json = {
        '_id': '64f1234567890',
        'title': 'Courier assigned',
        'body': 'Driver has picked up your order',
        'type': 'delivery',
        'isRead': false,
        'createdAt': '2026-09-21T04:00:00.000Z',
        'data': {
          'orderId': 'ORD-999',
          'voucherCode': 'SAVE10',
          'discount': 10,
          'status_delivery': 'shipped',
        },
      };

      final model = NotificationModel.fromJson(json);

      expect(model.id, '64f1234567890');
      expect(model.title, 'Courier assigned');
      expect(model.type, 'delivery');
      expect(model.isRead, isFalse);
      expect(model.orderId, 'ORD-999');
      expect(model.voucherCode, 'SAVE10');
      expect(model.discount, 10);
      expect(model.statusDelivery, 'shipped');
      expect(model.isDelivery, isTrue);
      expect(model.isVoucher, isTrue);
    });

    test('NotificationListResponse parses list, unreadCount, and pagination', () {
      final json = {
        'notifications': [
          {
            '_id': '1',
            'title': 'Promo',
            'body': 'Sale',
            'type': 'promo',
            'isRead': false,
          }
        ],
        'unreadCount': 1,
        'pagination': {'total': 1, 'page': 1, 'limit': 20, 'totalPages': 1},
      };

      final res = NotificationListResponse.fromJson(json);
      expect(res.notifications.length, 1);
      expect(res.unreadCount, 1);
      expect(res.pagination?.total, 1);
    });
  });

  group('NotificationRepository Tests', () {
    test('getNotifications retrieves list and unread count', () async {
      final res = await repository.getNotifications();
      expect(res.notifications.length, 3);
      expect(res.unreadCount, 2);
      expect(mockAdapter.getCount, 1);
    });

    test('markAsRead calls endpoint and returns updated model', () async {
      final updated = await repository.markAsRead('notif-1');
      expect(updated, isNotNull);
      expect(updated?.isRead, isTrue);
      expect(mockAdapter.markReadCount, 1);
    });

    test('markAllAsRead calls read-all endpoint', () async {
      final success = await repository.markAllAsRead();
      expect(success, isTrue);
      expect(mockAdapter.markAllCount, 1);
    });
  });

  group('NotificationsController Tests', () {
    late NotificationsController controller;

    setUp(() async {
      controller = NotificationsController(
        repository: repository,
        storage: storage,
      );
      await controller.fetchNotifications();
    });

    test('Loads notifications and sets unreadCount correctly', () {
      expect(controller.notifications.length, 3);
      expect(controller.unreadCount.value, 2);
      expect(controller.ordersCount, 1);
      expect(controller.vouchersCount, 1);
      expect(controller.promosCount, 1);
    });

    test('Filters notifications by category', () {
      controller.setFilter('orders');
      expect(controller.filteredNotifications.length, 1);
      expect(controller.filteredNotifications.first.type, 'delivery');

      controller.setFilter('vouchers');
      expect(controller.filteredNotifications.length, 1);
      expect(controller.filteredNotifications.first.type, 'voucher');

      controller.setFilter('promos');
      expect(controller.filteredNotifications.length, 1);
      expect(controller.filteredNotifications.first.type, 'promo');

      controller.setFilter('all');
      expect(controller.filteredNotifications.length, 3);
    });

    test('markAsRead updates item optimistically and decrements unreadCount', () async {
      await controller.markAsRead('notif-1');
      expect(controller.notifications.firstWhere((n) => n.id == 'notif-1').isRead, isTrue);
      expect(controller.unreadCount.value, 1);
    });

    test('markAllAsRead updates all items and clears unreadCount', () async {
      await controller.markAllAsRead();
      expect(controller.unreadCount.value, 0);
      expect(controller.notifications.every((n) => n.isRead), isTrue);
    });

    test('copyVoucherCode sets copiedVoucherCode value', () {
      controller.copyVoucherCode('APPLE15');
      expect(controller.copiedVoucherCode.value, 'APPLE15');
    });

    test('didChangeAppLifecycleState refreshes notifications on app resume', () async {
      mockAdapter.getCount = 0;
      controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(mockAdapter.getCount, greaterThan(0));
    });

    test('loadMoreNotifications loads next page items and updates pagination state', () async {
      expect(controller.notifications.length, 3);
      expect(controller.currentPage.value, 1);
      expect(controller.hasMore.value, isTrue);

      await controller.loadMoreNotifications();

      expect(controller.notifications.length, 4);
      expect(controller.currentPage.value, 2);
      expect(controller.hasMore.value, isFalse);
      expect(controller.notifications.any((n) => n.id == 'notif-4'), isTrue);
    });
  });
}
