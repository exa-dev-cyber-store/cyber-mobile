import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/notification_model.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../../../routes/app_pages.dart';

class NotificationsController extends GetxController with WidgetsBindingObserver {
  final NotificationRepository _repository;
  final LocalStorageService _storage;

  NotificationsController({
    NotificationRepository? repository,
    LocalStorageService? storage,
  })  : _storage = storage ?? LocalStorageService.instance,
        _repository = repository ?? NotificationRepository(storage ?? LocalStorageService.instance);

  final notifications = <NotificationModel>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final isLoadingMore = false.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalNotifications = 0.obs;
  final hasMore = true.obs;
  final selectedFilter = 'all'.obs; // 'all', 'orders', 'vouchers', 'promos'
  final copiedVoucherCode = ''.obs;
  final ScrollController scrollController = ScrollController();

  bool get isAuthenticated => _storage.hasToken;

  @override
  void onInit() {
    super.onInit();
    _setupScrollListener();
    try {
      WidgetsBinding.instance.addObserver(this);
    } catch (_) {}
    if (isAuthenticated) {
      fetchNotifications();
    }
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.hasClients &&
          scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        if (!isLoadingMore.value && hasMore.value && !isLoading.value && !isRefreshing.value) {
          loadMoreNotifications();
        }
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (_) {}
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AppLogger.d('App resumed from background, syncing notifications & badge', 'NOTIFICATION');
      if (isAuthenticated) {
        fetchNotifications(isSilent: true);
      }
    }
  }

  // Filtered list getter
  List<NotificationModel> get filteredNotifications {
    switch (selectedFilter.value) {
      case 'orders':
        return notifications.where((n) => n.isDelivery).toList();
      case 'vouchers':
        return notifications.where((n) => n.isVoucher).toList();
      case 'promos':
        return notifications.where((n) => n.isPromo || (!n.isDelivery && !n.isVoucher)).toList();
      case 'all':
      default:
        return notifications;
    }
  }

  int get ordersCount => notifications.where((n) => n.isDelivery).length;
  int get vouchersCount => notifications.where((n) => n.isVoucher).length;
  int get promosCount => notifications.where((n) => n.isPromo || (!n.isDelivery && !n.isVoucher)).length;

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }



  Future<void> fetchNotifications({bool isSilent = false}) async {
    if (!isAuthenticated) {
      notifications.clear();
      unreadCount.value = 0;
      currentPage.value = 1;
      hasMore.value = false;
      return;
    }

    try {
      if (!isSilent && notifications.isEmpty) {
        isLoading.value = true;
      } else {
        isRefreshing.value = true;
      }

      currentPage.value = 1;
      final response = await _repository.getNotifications(page: 1, limit: 20);
      notifications.assignAll(response.notifications);
      unreadCount.value = response.unreadCount;

      if (response.pagination != null) {
        totalPages.value = response.pagination!.totalPages;
        totalNotifications.value = response.pagination!.total;
        hasMore.value = currentPage.value < totalPages.value;
      } else {
        hasMore.value = response.notifications.length >= 20;
      }
    } catch (e) {
      AppLogger.w('Failed to fetch notifications: $e', 'NOTIFICATION');
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> loadMoreNotifications() async {
    if (isLoadingMore.value || !hasMore.value || isLoading.value || isRefreshing.value || !isAuthenticated) {
      return;
    }

    try {
      isLoadingMore.value = true;
      final nextPage = currentPage.value + 1;
      final response = await _repository.getNotifications(page: nextPage, limit: 20);

      // Prevent duplicate IDs if items were updated or pushed concurrently
      final existingIds = notifications.map((n) => n.id).toSet();
      final newItems = response.notifications.where((n) => !existingIds.contains(n.id)).toList();
      notifications.addAll(newItems);

      currentPage.value = nextPage;
      unreadCount.value = response.unreadCount;

      if (response.pagination != null) {
        totalPages.value = response.pagination!.totalPages;
        totalNotifications.value = response.pagination!.total;
        hasMore.value = currentPage.value < totalPages.value;
      } else {
        hasMore.value = newItems.isNotEmpty && response.notifications.length >= 20;
      }
    } catch (e) {
      AppLogger.w('Failed to load more notifications: $e', 'NOTIFICATION');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;

    final currentItem = notifications[index];
    if (currentItem.isRead) return;

    // Optimistic UI update
    notifications[index] = currentItem.copyWith(isRead: true);
    if (unreadCount.value > 0) {
      unreadCount.value--;
    }

    try {
      await _repository.markAsRead(id);
    } catch (e) {
      AppLogger.w('Background mark-as-read failed: $e', 'NOTIFICATION');
    }
  }

  Future<void> markAllAsRead() async {
    if (unreadCount.value == 0 && notifications.every((n) => n.isRead)) {
      return;
    }

    // Optimistic UI update
    notifications.assignAll(
      notifications.map((n) => n.copyWith(isRead: true)).toList(),
    );
    unreadCount.value = 0;

    try {
      await _repository.markAllAsRead();
      AppSnackbar.success('All notifications marked as read', title: 'Notifications');
    } catch (e) {
      AppLogger.w('Failed to mark all read: $e', 'NOTIFICATION');
    }
  }

  void copyVoucherCode(String code) {
    if (code.isEmpty) return;

    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: code));
    copiedVoucherCode.value = code;

    AppSnackbar.success(
      'Voucher code $code copied to clipboard!',
      title: 'Voucher Copied',
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (copiedVoucherCode.value == code) {
        copiedVoucherCode.value = '';
      }
    });
  }

  void handleNotificationTap(NotificationModel item) {
    if (!item.isRead) {
      markAsRead(item.id);
    }

    if (item.isDelivery || item.orderId != null) {
      Get.toNamed(Routes.ORDER_HISTORY);
      return;
    }

    if (item.link != null && item.link!.isNotEmpty) {
      final link = item.link!.toLowerCase();
      if (link.contains('order')) {
        Get.toNamed(Routes.ORDER_HISTORY);
      } else if (link.contains('cart')) {
        Get.toNamed(Routes.CART);
      } else if (link.contains('detail-product') || link.contains('product')) {
        Get.toNamed(Routes.SEARCH_PRODUCT);
      } else {
        Get.toNamed(Routes.HOME);
      }
      return;
    }

    if (item.isVoucher && item.voucherCode != null) {
      copyVoucherCode(item.voucherCode!);
    }
  }
}
