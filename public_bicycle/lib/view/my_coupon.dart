import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../vm/coupon_controller.dart';
import 'mycoupon_detail.dart';
import '../model/coupon.dart';
import '../model/coupon_usage.dart';

class MyCoupon extends StatelessWidget {
  MyCoupon({super.key}) {
    // 예시 데이터 추가
    _addSampleData();
  }

  final couponController = Get.put(CouponController()); // Controller 초기화

  void _addSampleData() {
    // 예시 쿠폰 데이터
    final sampleCoupons = [
      Coupon(
        couponId: 'KFC001',
        storeId: 'ST001',
        storeName: 'KFC',
        discountAmount: 40,
        issueDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        userId: 'USER001',
        location: '672.대광고등학교 주변',
        category: '음식점',
      ),
      Coupon(
        couponId: 'STAR001',
        storeId: 'ST002',
        storeName: '스타벅스',
        discountAmount: 50,
        issueDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(days: 15)),
        userId: 'USER001',
        location: '672.대광고등학교 주변',
        category: '카페',
      ),
      Coupon(
        couponId: 'SUNG001',
        storeId: 'ST003',
        storeName: '성수오땅',
        discountAmount: 30,
        issueDate: DateTime.now(),
        expiryDate: DateTime.now().subtract(const Duration(days: 1)), // 만료된 쿠폰 예시
        userId: 'USER001',
        location: '672.대광고등학교 주변',
        category: '음식점',
        isUsed: true,
      ),
    ];

    // 예시 쿠폰 사용 데이터
    final sampleUsages = sampleCoupons.map((coupon) => CouponUsage(
          userId: 'USER001',
          couponId: coupon.couponId,
          receivedDate: DateTime.now(),
        )).toList();

    // 컨트롤러에 예시 데이터 설정
    couponController.availableCoupons.value = sampleCoupons;
    couponController.userCoupons.value = sampleUsages;
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
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: couponController.userCoupons.length,
                itemBuilder: (context, index) {
                  final couponUsage = couponController.userCoupons[index];
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
                          Text(
                            '유효기간: ${coupon.expiryDate.toString().split(' ')[0]}',
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
                          if (coupon.isExpired || coupon.isUsed)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: coupon.isUsed ? Colors.grey[100] : Colors.red[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                coupon.isUsed ? '사용완료' : '만료됨',
                                style: TextStyle(
                                  color: coupon.isUsed ? Colors.grey : Colors.red,
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