import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../vm/coupon_controller.dart';
import 'mycoupon_detail.dart';

class MyCoupon extends StatelessWidget {
  MyCoupon({super.key});

  final couponController = Get.find<CouponController>();

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
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: couponController.userCoupons.length,
                itemBuilder: (context, index) {
                  final couponUsage = couponController.userCoupons[index];
                  // null safety 적용하여 쿠폰 정보 가져오기
                  final coupon = couponController.availableCoupons
                      .firstWhereOrNull((c) => c.couponId == couponUsage.couponId);
                  
                  if (coupon == null) {
                    return const SizedBox.shrink();
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.local_offer,
                          color: Colors.green[600],
                        ),
                      ),
                      title: Text(
                        coupon.storeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${coupon.discountAmount.toInt()}% 할인'),
                          if (coupon.location != null)
                            Text(
                              coupon.location!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (coupon.isExpired)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '만료됨',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      onTap: () => Get.to(() => MyCouponDetail(), arguments: coupon),
                    ),
                  );
                },
              ),
      ),
    );
  }
}