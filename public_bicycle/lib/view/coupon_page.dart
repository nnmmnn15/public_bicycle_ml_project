import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../vm/coupon_controller.dart';
import '../vm/login_handler.dart';
import 'my_coupon.dart';

class CouponPage extends StatelessWidget {
  CouponPage({super.key}) {
    couponController.loadCoupons();
  }

  final couponController = Get.put(CouponController());
  final loginHandler = Get.find<LoginHandler>();
  final LatLng schoolLocation = const LatLng(37.5445, 127.0567);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('주변 쿠폰 받기'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(
            height: screenHeight * 0.4,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: schoolLocation,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: schoolLocation,
                      radius: 500,
                      color: Colors.blue.withOpacity(0.3),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: schoolLocation,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (couponController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: couponController.availableCoupons.length,
                itemBuilder: (context, index) {
                  final coupon = couponController.availableCoupons[index];
                  return _buildCouponItem(
                    coupon['store_name'],
                    '할인쿠폰 ${coupon['discount_amount']}%',
                    () async {
                      final userId = loginHandler.box.read('id');
                      if (userId != null) {
                        await couponController.receiveCoupon(
                          coupon['coupon_id'],
                          userId,
                        );
                      } else {
                        Get.snackbar(
                          '오류',
                          '로그인이 필요합니다.',
                          backgroundColor: Colors.red[100],
                        );
                      }
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponItem(String storeName, String discount, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        title: Text(storeName),
        subtitle: Text(discount),
        trailing: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('쿠폰받기'),
        ),
      ),
    );
  }
}