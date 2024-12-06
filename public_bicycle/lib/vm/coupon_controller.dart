import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../vm/login_handler.dart';

class CouponController extends GetxController {
  final loginHandler = Get.find<LoginHandler>();
  final RxList<Map<String, dynamic>> availableCoupons = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> userCoupons = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  final Rx<double?> currentLat = Rx<double?>(37.5445);
  final Rx<double?> currentLng = Rx<double?>(127.0567);

  @override
  void onInit() {
    super.onInit();
    loadCoupons();
  }

  Future<void> loadCoupons() async {
    try {
      isLoading.value = true;
      final token = await loginHandler.secureStorage.read(key: 'accessToken');
      if (token == null) throw Exception("Token not found");

      final response = await http.get(
        Uri.parse('${loginHandler.serverurl}/login/coupons/available'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        availableCoupons.value = List<Map<String, dynamic>>.from(data['coupons']);
        update();
      }
    } catch (e) {
      print('Error loading coupons: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserCoupons(String userId) async {
  try {
    isLoading.value = true;
    final token = await loginHandler.secureStorage.read(key: 'accessToken');
    if (token == null) throw Exception("Token not found");

    final response = await http.get(
      Uri.parse('${loginHandler.serverurl}/login/user/$userId/coupons'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final coupons = (data['coupons'] as List).map((coupon) => 
        Map<String, dynamic>.from(coupon)
      ).toList();
      userCoupons.value = coupons;
      update();
    }
  } catch (e) {
    print('Error loading user coupons: $e');
  } finally {
    isLoading.value = false;
  }
}

Future<void> receiveCoupon(String? couponId, String? userId) async {
  if (couponId == null || userId == null) {
    Get.snackbar('오류', '쿠폰 정보가 올바르지 않습니다.');
    return;
  }

  try {
    final token = await loginHandler.secureStorage.read(key: 'accessToken');
    if (token == null) throw Exception("Token not found");

    print('Receiving coupon: $couponId for user: $userId');

    final response = await http.post(
      Uri.parse('${loginHandler.serverurl}/login/coupons/receive/$couponId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      await loadCoupons();
      Get.snackbar(
        '성공', 
        '쿠폰이 발급되었습니다.',
        backgroundColor: Colors.green[100],
      );
    } else {
      throw Exception('Failed to receive coupon: ${response.body}');
    }
  } catch (e) {
    print('Error receiving coupon: $e');
    Get.snackbar(
      '오류',
      '쿠폰 발급 중 오류가 발생했습니다.',
      backgroundColor: Colors.red[100],
    );
  }
}
}