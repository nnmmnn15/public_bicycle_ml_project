import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../model/coupon.dart';
import '../model/store.dart';
import '../model/coupon_usage.dart';

class CouponController extends GetxController {
  final RxList<Coupon> availableCoupons = <Coupon>[].obs;
  final RxList<CouponUsage> userCoupons = <CouponUsage>[].obs;
  final RxBool isLoading = false.obs;


    // 대광고등학교 위치 (nullable로 변경)
  final Rx<double?> currentLat = Rx<double?>(37.5445);
  final Rx<double?> currentLng = Rx<double?>(127.0567);
  
  
  @override
  void onInit() {
    super.onInit();
    loadCoupons();
  }

  Future<void> loadCoupons() async {
    isLoading.value = true;
    try {
      availableCoupons.value = [
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
          isUsed: false,
        ),
        Coupon(
          couponId: 'STAR001',
          storeId: 'ST002',
          storeName: '스타벅스',
          discountAmount: 50,
          issueDate: DateTime.now(),
          expiryDate: DateTime.now().add(const Duration(days: 30)),
          userId: 'USER001',
          location: '672.대광고등학교 주변',
          category: '카페',
          isUsed: false,
        ),
        Coupon(
          couponId: 'SUNG001',
          storeId: 'ST003',
          storeName: '성수오땅',
          discountAmount: 30,
          issueDate: DateTime.now(),
          expiryDate: DateTime.now().add(const Duration(days: 30)),
          userId: 'USER001',
          location: '672.대광고등학교 주변',
          category: '음식점',
          isUsed: false,
        ),
        Coupon(
          couponId: 'HYUN001',
          storeId: 'ST004',
          storeName: '현대붕어빵',
          discountAmount: 40,
          issueDate: DateTime.now(),
          expiryDate: DateTime.now().add(const Duration(days: 30)),
          userId: 'USER001',
          location: '672.대광고등학교 주변',
          category: '디저트',
          isUsed: false,
        ),
      ];
    } catch (e) {
      print('Error loading coupons: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserCoupons(String userId) async {
    isLoading.value = true;
    try {
      // 실제 DB 연동 시 구현
      final coupons = userCoupons.where((c) => c.userId == userId).toList();
      userCoupons.value = coupons;
    } catch (e) {
      print('Error loading user coupons: $e');
    } finally {
      isLoading.value = false;
    }
  }


  
  Future<void> receiveCoupon(String? couponId, String? userId) async {
    if (couponId == null || userId == null) {
      Get.snackbar(
        '오류',
        '쿠폰 정보가 올바르지 않습니다.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final coupon = availableCoupons.firstWhereOrNull((c) => c.couponId == couponId);
      
      if (coupon == null) {
        throw Exception('쿠폰을 찾을 수 없습니다.');
      }

      final couponUsage = CouponUsage(
        userId: userId,
        couponId: couponId,
        receivedDate: DateTime.now(),
      );
      
      userCoupons.add(couponUsage);
      
      Get.snackbar(
        '쿠폰 발급 완료',
        '${coupon.storeName} 할인쿠폰이 발급되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        '오류',
        '쿠폰 발급 중 오류가 발생했습니다.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> useCoupon(String? couponId) async {
    if (couponId == null) return;

    try {
      final index = availableCoupons.indexWhere((c) => c.couponId == couponId);
      if (index != -1) {
        final coupon = availableCoupons[index];
        final updatedCoupon = Coupon(
          couponId: coupon.couponId,
          storeId: coupon.storeId,
          storeName: coupon.storeName,
          discountAmount: coupon.discountAmount,
          issueDate: coupon.issueDate,
          expiryDate: coupon.expiryDate,
          userId: coupon.userId,
          isUsed: true,
          usedTime: DateTime.now(),
          location: coupon.location,
          category: coupon.category,
          issueNumber: coupon.issueNumber,
        );
        availableCoupons[index] = updatedCoupon;
        update();
      }
    } catch (e) {
      print('Error using coupon: $e');
    }
  }

  Future<List<Coupon>> getValidCoupons() async {
    return availableCoupons.where((coupon) => coupon.isAvailable).toList();
  }
}


