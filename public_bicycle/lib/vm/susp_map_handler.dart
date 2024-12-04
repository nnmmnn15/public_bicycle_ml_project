import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:latlong2/latlong.dart' as latlng;
import '../model/suspend_station.dart';

class SuspMapHandler extends GetxController {
  bool canRun = false;
  bool isRun = false;
  final mapController = MapController();
  final detailMapController = MapController();

  double? curLatData;
  double? curLngData;

  Position? currentPosition;

  final markerList = <Marker>[].obs();

  late List<String> namelist;

  late List<SuspendStation> stationList;

  String mainText = '연장 선택을 할 정류장을 골라주세요!';

  int? mainIndex;

  @override
  void onInit() {
    super.onInit();
    checkLocationPermission();
  }

  latlng.LatLng startPoint =
      const latlng.LatLng(37.56640471391909, 126.97804621813793);

  /// gps가져와도되나용
  checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      canRun = true;
      await getCurrentLocation();
      await seongdongMarker();
      update();
    }
  }

  // 로케이션 가져올게용
  getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();

    currentPosition = position;
    curLatData = currentPosition!.latitude;
    curLngData = currentPosition!.longitude;
    startPoint = latlng.LatLng(curLatData!, curLngData!);
    isRun = true;

    print(curLatData);
    print(curLngData);
  }

  seongdongMarker() async {
    /// 성동구의 마커들 가져오기
    /// 이부분은 가져와서 바꾸기
    stationList = [
      SuspendStation(
          lat: curLatData! + 0.001,
          lng: curLngData! - 0.001,
          name: '강남역4번출구',
          valid: true),
      SuspendStation(
          lat: curLatData! + 0.004,
          lng: curLngData! + 0.005,
          name: '강남현대아파트앞',
          valid: false),
    ];
    markerList.add(
      Marker(
        point: latlng.LatLng(curLatData!, curLngData!),
        child: const Icon(Icons.location_on, color: Colors.red, size: 30.0),
      ),
    );
    List<Marker> stationMarkerList = List.generate(
      stationList.length,
      (index) {
        return Marker(
          point: latlng.LatLng(stationList[index].lat, stationList[index].lng),
          child: stationList[index].valid
              ? InkWell(
                  onTap: () {
                    mainIndex = index;
                    certainMarkerCliccked(stationList[index].name);
                  },
                  child: Icon(Icons.location_on, color: Colors.green[300]),
                )
              : const Icon(Icons.location_on, color: Colors.grey, size: 30.0),
        );
      },
    );
    markerList.addAll(stationMarkerList);
  }

  certainMarkerCliccked(String stationName) {
    mainText = '정류장 : $stationName';
    update();
  }
}
