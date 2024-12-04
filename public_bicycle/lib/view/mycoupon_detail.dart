import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../model/coupon.dart';

class MyCouponDetail extends StatelessWidget {
  MyCouponDetail({super.key});

  final Coupon coupon = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('쿠폰 상세'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      coupon.storeName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${coupon.discountAmount.toInt()}% 할인쿠폰',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green[600],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (!coupon.isUsed) ...[
                      QrImageView(
                        data: coupon.couponId,
                        size: 200,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '쿠폰 번호: ${coupon.couponId}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ] else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '사용 완료된 쿠폰입니다',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      '유효기간: ${coupon.expiryDate.toString().split(' ')[0]}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}