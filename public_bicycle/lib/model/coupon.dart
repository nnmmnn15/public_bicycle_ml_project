class Coupon {
  final String couponId;
  final String storeId;
  final String storeName;
  final double discountAmount;
  final DateTime issueDate;
  final DateTime expiryDate;
  final bool isUsed;
  final DateTime? usedTime;
  final String? issueNumber;
  final String userId;
  final String? location;
  final String? category;

  Coupon({
    required this.couponId,
    required this.storeId,
    required this.storeName,
    required this.discountAmount,
    required this.issueDate,
    required this.expiryDate,
    required this.userId,
    this.isUsed = false,
    this.usedTime,
    this.issueNumber,
    this.location,
    this.category,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      couponId: json['coupon_id'] ?? '',
      storeId: json['store_id'] ?? '',
      storeName: json['store_name'] ?? '',
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      issueDate: DateTime.parse(json['issue_date'] ?? DateTime.now().toIso8601String()),
      expiryDate: DateTime.parse(json['expiry_date'] ?? DateTime.now().toIso8601String()),
      userId: json['user_id'] ?? '',
      isUsed: json['is_used'] == 1,
      usedTime: json['used_time'] != null ? DateTime.parse(json['used_time']) : null,
      issueNumber: json['issue_number'],
      location: json['location'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coupon_id': couponId,
      'store_id': storeId,
      'store_name': storeName,
      'discount_amount': discountAmount,
      'issue_date': issueDate.toIso8601String(),
      'expiry_date': expiryDate.toIso8601String(),
      'user_id': userId,
      'is_used': isUsed ? 1 : 0,
      'used_time': usedTime?.toIso8601String(),
      'issue_number': issueNumber,
      'location': location,
      'category': category,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isAvailable => !isUsed && !isExpired;
}