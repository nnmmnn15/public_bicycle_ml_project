import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../vm/coupon_controller.dart';
import '../vm/login_handler.dart';
import 'mycoupon_detail.dart';

class MyCoupon extends StatefulWidget {
  const MyCoupon({super.key});

  @override
  State<MyCoupon> createState() => _MyCouponState();
}

class _MyCouponState extends State<MyCoupon> {
  final couponController = Get.put(CouponController());
  final loginHandler = Get.find<LoginHandler>();
  
  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    final userId = loginHandler.box.read('id');
    if (userId != null) {
      await couponController.loadUserCoupons(userId);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 쿠폰함'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Obx(
        () => couponController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadCoupons,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: couponController.userCoupons.length,
                  itemBuilder: (context, index) {
                    final coupon = couponController.userCoupons[index];
                    final isUsed = coupon['usage_date'] != null;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.local_offer, color: Colors.green[600]),
                        ),
                        title: Text(
                          coupon['store_name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${coupon['discount_amount']}% 할인'),
                            Text(
                              '받은 날짜: ${_formatDate(coupon['received_date'])}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                            Text(
                              '유효기간: ${_formatDate(coupon['expiry_date'])}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: isUsed
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '사용완료',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : const Icon(Icons.chevron_right),
                        onTap: () => Get.to(() => MyCouponDetail(), arguments: coupon),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}