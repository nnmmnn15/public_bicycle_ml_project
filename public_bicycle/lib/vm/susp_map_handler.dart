import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:public_bicycle/model/suspend_station.dart';

class SuspMapHandler extends GetxController {
  final serverurl =
      // 'http://10.0.2.2';
      'http://127.0.0.1:8000';
  bool canRun = false;
  bool isRun = false;
  final mapController = MapController();
  // final detailMapController = MapController();

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
      // 스테이션 위치
      // 불러와야함
      await nearStation();
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
  }

  seongdongMarker() async {
    markerList.clear();
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
          child: stationList[index].distance <= 25.0
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

  nearStation() async {
    List<SuspendStation> nearSt = [];
    var url = Uri.parse(
        '$serverurl/station/suspend_station?lat=${curLatData!}&lng=${curLngData!}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      final result = dataConvertedJSON['results'];
      for (int i = 0; i < result.length; i++) {
        // print(result[i]);
        nearSt.add(SuspendStation(
            lat: result[i]['lat'],
            lng: result[i]['lng'],
            name: result[i]['name'],
            distance: result[i]['distance']));
      }
      stationList = nearSt;
    }
  }
}
