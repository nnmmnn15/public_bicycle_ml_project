import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../vm/login_handler.dart';

class MyCouponDetail extends StatefulWidget {
  const MyCouponDetail({super.key});

  @override
  State<MyCouponDetail> createState() => _MyCouponDetailState();
}

class _MyCouponDetailState extends State<MyCouponDetail> {
  final loginHandler = Get.find<LoginHandler>();
  final Map<String, dynamic> couponData = Get.arguments;
  
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
                      couponData['store_name'] ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${couponData['discount_amount']}% 할인쿠폰',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green[600],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (couponData['is_used'] != '1') ...[
                      QrImageView(
                        data: couponData['coupon_id'] ?? '',
                        size: 200,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '쿠폰 번호: ${couponData['coupon_id']}',
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
                      '유효기간: ${_formatDate(couponData['expiry_date'])}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '받은 날짜: ${_formatDate(couponData['received_date'])}',
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      print('Date formatting error: $e for date: $dateStr');
      return dateStr;
    }
  }
}