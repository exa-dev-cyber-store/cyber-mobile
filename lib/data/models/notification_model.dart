class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    if (json['createdAt'] != null) {
      parsedDate = DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return NotificationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: (json['type']?.toString().toLowerCase() ?? 'general'),
      isRead: json['isRead'] == true,
      createdAt: parsedDate,
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : (json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'body': body,
        'type': type,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
        if (data != null) 'data': data,
      };

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  // Convenience helpers
  String? get orderId => data?['orderId']?.toString();
  String? get voucherCode => data?['voucherCode']?.toString();
  num? get discount {
    final raw = data?['discount'];
    if (raw is num) return raw;
    if (raw != null) return num.tryParse(raw.toString());
    return null;
  }

  String? get link => data?['link']?.toString();
  String? get statusDelivery =>
      data?['status_delivery']?.toString() ?? data?['status']?.toString();

  bool get isDelivery => type == 'delivery' || orderId != null;
  bool get isVoucher => type == 'voucher' || voucherCode != null;
  bool get isPromo => type == 'promo';
}

class NotificationPagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const NotificationPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory NotificationPagination.fromJson(Map<String, dynamic> json) {
    return NotificationPagination(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

class NotificationListResponse {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final NotificationPagination? pagination;

  const NotificationListResponse({
    required this.notifications,
    required this.unreadCount,
    this.pagination,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['notifications'] ?? json['data']?['notifications'] ?? [];
    final list = rawList is List
        ? rawList.map((item) => NotificationModel.fromJson(Map<String, dynamic>.from(item))).toList()
        : <NotificationModel>[];

    final rawUnread = json['unreadCount'] ?? json['data']?['unreadCount'];
    final unread = rawUnread is num ? rawUnread.toInt() : list.where((n) => !n.isRead).length;

    NotificationPagination? pagination;
    final rawPagination = json['pagination'] ?? json['data']?['pagination'];
    if (rawPagination is Map) {
      pagination = NotificationPagination.fromJson(Map<String, dynamic>.from(rawPagination));
    }

    return NotificationListResponse(
      notifications: list,
      unreadCount: unread,
      pagination: pagination,
    );
  }
}
