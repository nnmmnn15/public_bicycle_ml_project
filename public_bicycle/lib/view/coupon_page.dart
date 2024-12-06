import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../vm/coupon_controller.dart';
import '../vm/login_handler.dart';
import '../vm/susp_map_handler.dart';

class CouponPage extends StatelessWidget {
  CouponPage({super.key}) {
    print('Initializing CouponPage...');
    // 맵 핸들러에서 현재 위치 가져오기
    final mapHandler = Get.find<SuspMapHandler>();
    currentLocation = LatLng(
      mapHandler.curLatData ?? 37.5445,
      mapHandler.curLngData ?? 127.0567
    );
    print('Current location: ${currentLocation.latitude}, ${currentLocation.longitude}');
    _loadCouponsWithDebug();
  }

  final couponController = Get.put(CouponController());
  final loginHandler = Get.find<LoginHandler>();
  late final LatLng currentLocation;

  Future<void> _loadCouponsWithDebug() async {
    try {
      print('Starting to load coupons...');
      final token = await loginHandler.secureStorage.read(key: 'accessToken');
      print('Token retrieved: ${token != null}');

      await couponController.loadCoupons();
      print('Coupons loaded: ${couponController.availableCoupons.length}');
    } catch (e, stackTrace) {
      print('Error in _loadCouponsWithDebug: $e');
      print('Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building CouponPage widget');
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
            height: screenHeight * 0.3,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: currentLocation,
                initialZoom: 16.0,
                minZoom: 14.0,
                maxZoom: 19.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: currentLocation,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: currentLocation,
                      radius: 1525,
                      useRadiusInMeter: true,
                      color: Colors.blue.withOpacity(0.3),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              print('Rebuilding coupon list. Loading: ${couponController.isLoading.value}');
              print('Available coupons: ${couponController.availableCoupons.length}');

              if (couponController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (couponController.availableCoupons.isEmpty) {
                print('No coupons available');
                return const Center(child: Text('사용 가능한 쿠폰이 없습니다.'));
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: couponController.availableCoupons.length,
                itemBuilder: (context, index) {
                  final coupon = couponController.availableCoupons[index];
                  print('Building coupon item: ${coupon['store_name']}');
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(coupon['store_name'] ?? ''),
                      subtitle: Text('할인쿠폰 ${coupon['discount_amount']}%'),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          final userId = loginHandler.box.read('id');
                          print('Receiving coupon. User ID: $userId');
                          
                          if (userId != null) {
                            try {
                              await couponController.receiveCoupon(
                                coupon['coupon_id'],
                                userId,
                              );
                              print('Coupon received successfully');
                            } catch (e) {
                              print('Error receiving coupon: $e');
                            }
                          } else {
                            print('User not logged in');
                            Get.snackbar(
                              '오류',
                              '로그인이 필요합니다.',
                              backgroundColor: Colors.red[100],
                            );
                          }
                        },
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
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}