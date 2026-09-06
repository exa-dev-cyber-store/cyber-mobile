import '../../core/utils/currency_formatter.dart';

class VoucherModel {
  final String id;
  final String code;
  final String title;
  final String discountType; // 'percentage' | 'fixed'
  final int discountValue;
  final int minPurchase;
  final int maxDiscount;
  final bool isPublic;
  final bool isActive;
  final DateTime? validUntil;

  VoucherModel({
    required this.id,
    required this.code,
    required this.title,
    required this.discountType,
    required this.discountValue,
    this.minPurchase = 0,
    this.maxDiscount = 0,
    this.isPublic = true,
    this.isActive = true,
    this.validUntil,
  });

  bool get isPercentage => discountType.toLowerCase() == 'percentage';

  String get formattedDiscountText {
    if (isPercentage) {
      return 'Diskon $discountValue%';
    } else {
      return 'Potongan ${CurrencyFormatter.format(discountValue)}';
    }
  }

  String get formattedRequirementText {
    if (minPurchase > 0) {
      return 'Min. belanja ${CurrencyFormatter.format(minPurchase)}';
    }
    return 'Tanpa minimum belanja';
  }

  int calculateEstimatedDiscount(int subtotal) {
    if (subtotal < minPurchase) return 0;

    int discount = 0;
    if (isPercentage) {
      discount = ((subtotal * discountValue) / 100).round();
      if (maxDiscount > 0 && discount > maxDiscount) {
        discount = maxDiscount;
      }
    } else {
      discount = discountValue > subtotal ? subtotal : discountValue;
    }
    return discount;
  }

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      discountType: json['discountType']?.toString() ?? 'percentage',
      discountValue: (json['discountValue'] as num?)?.toInt() ?? 0,
      minPurchase: (json['minPurchase'] as num?)?.toInt() ?? 0,
      maxDiscount: (json['maxDiscount'] as num?)?.toInt() ?? 0,
      isPublic: json['isPublic'] == true,
      isActive: json['isActive'] != false,
      validUntil: json['validUntil'] != null ? DateTime.tryParse(json['validUntil'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'code': code,
        'title': title,
        'discountType': discountType,
        'discountValue': discountValue,
        'minPurchase': minPurchase,
        'maxDiscount': maxDiscount,
        'isPublic': isPublic,
        'isActive': isActive,
        if (validUntil != null) 'validUntil': validUntil!.toIso8601String(),
      };
}

class ValidateVoucherResult {
  final VoucherModel voucher;
  final int discount;
  final int subtotal;
  final int finalSubtotal;
  final String message;

  ValidateVoucherResult({
    required this.voucher,
    required this.discount,
    required this.subtotal,
    required this.finalSubtotal,
    required this.message,
  });

  factory ValidateVoucherResult.fromJson(Map<String, dynamic> json, {String message = ''}) {
    final voucherData = json['voucher'] as Map<String, dynamic>? ?? {};
    return ValidateVoucherResult(
      voucher: VoucherModel.fromJson(voucherData),
      discount: (json['discount'] as num?)?.toInt() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toInt() ?? 0,
      finalSubtotal: (json['finalSubtotal'] as num?)?.toInt() ?? 0,
      message: message,
    );
  }
}
