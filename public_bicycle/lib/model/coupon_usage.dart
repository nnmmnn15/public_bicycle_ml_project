class CouponUsage {
  final String userId;
  final String couponId;
  final DateTime receivedDate;

  CouponUsage({
    required this.userId,
    required this.couponId,
    required this.receivedDate,
  });

  factory CouponUsage.fromJson(Map<String, dynamic> json) {
    return CouponUsage(
      userId: json['user_id'],
      couponId: json['coupon_id'],
      receivedDate: DateTime.parse(json['received_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'coupon_id': couponId,
      'received_date': receivedDate.toIso8601String(),
    };
  }
}