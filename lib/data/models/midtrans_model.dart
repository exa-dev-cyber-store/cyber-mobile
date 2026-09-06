class MidtransResponseModel {
  final String token;
  final String redirectUrl;

  MidtransResponseModel({
    required this.token,
    required this.redirectUrl,
  });

  factory MidtransResponseModel.fromJson(Map<String, dynamic> json) {
    return MidtransResponseModel(
      token: json['token']?.toString() ?? '',
      redirectUrl: json['redirect_url']?.toString() ?? json['redirectUrl']?.toString() ?? '',
    );
  }
}

class VaNumber {
  final String bank;
  final String vaNumber;

  VaNumber({required this.bank, required this.vaNumber});

  factory VaNumber.fromJson(Map<String, dynamic> json) {
    return VaNumber(
      bank: json['bank']?.toString() ?? '',
      vaNumber: json['va_number']?.toString() ?? '',
    );
  }
}

class MidtransAction {
  final String name;
  final String method;
  final String url;

  MidtransAction({required this.name, required this.method, required this.url});

  factory MidtransAction.fromJson(Map<String, dynamic> json) {
    return MidtransAction(
      name: json['name']?.toString() ?? '',
      method: json['method']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }
}

class MidtransChargeData {
  final String statusCode;
  final String statusMessage;
  final String transactionId;
  final String orderId;
  final String grossAmount;
  final String paymentType;
  final String transactionTime;
  final String transactionStatus;
  final String? fraudStatus;
  final List<VaNumber> vaNumbers;
  final String? permataVaNumber;
  final String? billerCode;
  final String? billKey;
  final String? paymentCode;
  final String? store;
  final String? qrString;
  final List<MidtransAction> actions;
  final String? expiryTime;

  MidtransChargeData({
    required this.statusCode,
    required this.statusMessage,
    required this.transactionId,
    required this.orderId,
    required this.grossAmount,
    required this.paymentType,
    required this.transactionTime,
    required this.transactionStatus,
    this.fraudStatus,
    this.vaNumbers = const [],
    this.permataVaNumber,
    this.billerCode,
    this.billKey,
    this.paymentCode,
    this.store,
    this.qrString,
    this.actions = const [],
    this.expiryTime,
  });

  factory MidtransChargeData.fromJson(Map<String, dynamic> json) {
    List<VaNumber> vaList = [];
    if (json['va_numbers'] is List) {
      vaList = (json['va_numbers'] as List)
          .map((v) => VaNumber.fromJson(v as Map<String, dynamic>))
          .toList();
    }

    List<MidtransAction> actionList = [];
    if (json['actions'] is List) {
      actionList = (json['actions'] as List)
          .map((a) => MidtransAction.fromJson(a as Map<String, dynamic>))
          .toList();
    }

    return MidtransChargeData(
      statusCode: json['status_code']?.toString() ?? '',
      statusMessage: json['status_message']?.toString() ?? '',
      transactionId: json['transaction_id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      grossAmount: json['gross_amount']?.toString() ?? '0',
      paymentType: json['payment_type']?.toString() ?? '',
      transactionTime: json['transaction_time']?.toString() ?? '',
      transactionStatus: json['transaction_status']?.toString() ?? '',
      fraudStatus: json['fraud_status']?.toString(),
      vaNumbers: vaList,
      permataVaNumber: json['permata_va_number']?.toString(),
      billerCode: json['biller_code']?.toString(),
      billKey: json['bill_key']?.toString(),
      paymentCode: json['payment_code']?.toString(),
      store: json['store']?.toString(),
      qrString: json['qr_string']?.toString(),
      actions: actionList,
      expiryTime: json['expiry_time']?.toString(),
    );
  }

  /// Primary VA Number (BCA, BNI, BRI, Permata)
  String get primaryVaNumber {
    if (vaNumbers.isNotEmpty) {
      return vaNumbers.first.vaNumber;
    }
    if (permataVaNumber != null && permataVaNumber!.isNotEmpty) {
      return permataVaNumber!;
    }
    return '';
  }

  /// Display Bank or Channel Name
  String get primaryBank {
    if (vaNumbers.isNotEmpty) {
      return vaNumbers.first.bank.toUpperCase();
    }
    if (permataVaNumber != null && permataVaNumber!.isNotEmpty) {
      return 'PERMATA';
    }
    if (billerCode != null && billerCode!.isNotEmpty) {
      return 'MANDIRI';
    }
    if (paymentType.toLowerCase() == 'qris') {
      return 'QRIS';
    }
    if (paymentType.toLowerCase() == 'gopay') {
      return 'GOPAY';
    }
    if (paymentCode != null && paymentCode!.isNotEmpty) {
      return store?.toUpperCase() ?? 'CONVENIENCE STORE';
    }
    return paymentType.toUpperCase();
  }

  /// QR Code Image URL (for QRIS)
  String? get qrCodeUrl {
    final action = actions.firstWhereOrNull((a) => a.name == 'generate-qr-code');
    return action?.url;
  }

  /// Deep Link URL (for GoPay)
  String? get deepLinkUrl {
    final action = actions.firstWhereOrNull((a) => a.name == 'deeplink-redirect');
    return action?.url;
  }

  /// Check if the payment is settled/paid
  bool get isPaid => transactionStatus == 'settlement' || transactionStatus == 'capture';

  /// Check if the payment is pending
  bool get isPending => transactionStatus == 'pending';

  /// Check if the payment is expired or cancelled
  bool get isExpired => transactionStatus == 'expire' || transactionStatus == 'cancel' || transactionStatus == 'deny';
}

class ChargeResponseModel {
  final String status;
  final String orderId;
  final MidtransChargeData charge;

  ChargeResponseModel({
    required this.status,
    required this.orderId,
    required this.charge,
  });

  factory ChargeResponseModel.fromJson(Map<String, dynamic> json) {
    final orderObj = json['order'];
    String ordId = '';
    if (orderObj is Map<String, dynamic>) {
      ordId = orderObj['_id']?.toString() ?? orderObj['id']?.toString() ?? '';
    } else if (json['orderId'] != null) {
      ordId = json['orderId'].toString();
    }

    final chargeMap = json['charge'] is Map<String, dynamic>
        ? json['charge'] as Map<String, dynamic>
        : json;

    return ChargeResponseModel(
      status: json['status']?.toString() ?? '',
      orderId: ordId,
      charge: MidtransChargeData.fromJson(chargeMap),
    );
  }
}

class PaymentStatusResponseModel {
  final String status;
  final String midtransStatus;
  final MidtransChargeData? charge;

  PaymentStatusResponseModel({
    required this.status,
    required this.midtransStatus,
    this.charge,
  });

  factory PaymentStatusResponseModel.fromJson(Map<String, dynamic> json) {
    MidtransChargeData? chargeData;
    if (json['charge'] is Map<String, dynamic>) {
      chargeData = MidtransChargeData.fromJson(json['charge'] as Map<String, dynamic>);
    }

    return PaymentStatusResponseModel(
      status: json['status']?.toString() ?? '',
      midtransStatus: json['midtransStatus']?.toString() ?? '',
      charge: chargeData,
    );
  }

  bool get isPaid => status == 'paid' || midtransStatus == 'settlement' || midtransStatus == 'capture';
}

extension _ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
