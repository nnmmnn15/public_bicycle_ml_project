import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapController extends GetxController {
  final Rx<LatLng> currentLocation = LatLng(37.5445, 127.0567).obs; // 대광고등학교 위치
  final RxDouble radius = 500.0.obs; // 반경 500m
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    isLoading.value = true;
    try {
      Position position = await Geolocator.getCurrentPosition();
      currentLocation.value = LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting location: $e');
    } finally {
      isLoading.value = false;
    }
  }
}