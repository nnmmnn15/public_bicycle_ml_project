import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:public_bicycle/model/rent.dart';
import 'package:public_bicycle/model/suspend_station.dart';
import 'package:public_bicycle/vm/myapi.dart';

class SuspMapHandler extends Myapi {
  final serverurl =
      // 'http://10.0.2.2';
      'http://127.0.0.1:8000';
  bool canRun = false;
  final isRun = false.obs;
  final mapController = MapController();
  final detailMapController = MapController();
  var currentRentInfo = Rxn<Rent>();
  double curLatData = 0;
  double curLngData = 0;

  Position? currentPosition;
  Timer? _timer;

  final markerList = <Marker>[].obs();

  late List<String> namelist;

  late List<SuspendStation> stationList;

  RxString mainText = '연장 선택을 할 정류장을 골라주세요!'.obs;

  int? mainIndex;

  @override
  void onInit() async{
    super.onInit();
    await checkLocationPermission();
    await getCurrentRent();
    await loadingComplete();
    await startLocationUpdates();
  }

  @override
  void onClose() {
    _timer?.cancel(); // 타이머 정리
    super.onClose();
  }

  latlng.LatLng startPoint =
      const latlng.LatLng(37.56640471391909, 126.97804621813793);

  bool isContainerVisible = false;
  latlng.LatLng? selectedPoint;


   // 위치 업데이트 시작
  startLocationUpdates() async{
    const duration = Duration(seconds: 5); // 10초 간격
    _timer = Timer.periodic(duration, (timer) async {
      await updateLocationAndCallAPI();
    });
  }

  // 위치 업데이트 및 API 호출
  Future<void> updateLocationAndCallAPI() async {
    try {
      // 현재 위치 가져오기
      // Position position = await getCurrentLocation();
      // currentPosition = position;
      // API 호출
      await callavaAPI(curLatData!, curLngData!);
      // await callProlongationAPI(
      //   position.latitude,
      //   position.longitude,
      // );
    } catch (e) {
      print("Error fetching location or calling API: $e");
    }
  }

  // API 호출
  callProlongationAPI(double lat, double lng) async {
    try {
      final response = await makeAuthenticatedRequest('$serverurl/rent/prolongation?resume=${1}&wantresume=${1}&lat=$lat&lng=$lng');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print(data['results'].runtimeType);
          if(data['results'] == 0){
            return 0;
          }
          return 1;
        } else {
          throw Exception("Failed to fetch user name: ${response.statusCode}");
        }
    } catch (e) {
      // print("Error calling API: $e");
    }
  }

   // API 호출
  callavaAPI(double lat, double lng) async {
    try {
      final response = await makeAuthenticatedRequest('http://127.0.0.1:8000/rent/ava_station?lat=$lat&lng=$lng');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          // print('data : ${data}');
          mainText.value = data['results'].toString();
          update();
        } else {
          throw Exception("Failed to fetch user name: ${response.statusCode}");
        }
    } catch (e) {
      // print("Error calling API: $e");
    }
  }



  showFloatingContainer(latlng.LatLng point) async{
    selectedPoint = point;
    isContainerVisible = true;
    update();
  }

  void hideFloatingContainer() {
    isContainerVisible = false;
    update();
  }


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
    curLatData =  37.55379868;
    curLngData = 127.04213715;
    startPoint = latlng.LatLng(curLatData!, curLngData!);
  }

  loadingComplete() async{
    isRun.value = true;
    update();
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
        // stationList[index].distance <= 25.0 ? 
        return Marker(
          point: latlng.LatLng(stationList[index].lat, stationList[index].lng),
          child: stationList[index].distance <= 25.0
              ? SizedBox(
                width: 50,
                height: 50,
                child: InkWell(
                  // radius: 25,
                    onTap: () {
                      // mainIndex = index;
                      // await
                      // certainMarkerCliccked(stationList[index].name);
                    },
                    child: Icon(Icons.location_on, color: Colors.green[300]),
                  ),
              )
              : const Icon(Icons.location_on, color: Colors.grey, size: 30.0),
        );
      },
    );
    markerList.addAll(stationMarkerList);
  }

  certainMarkerCliccked(String stationName) {
    mainText.value = '정류장 : $stationName';
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

  // Write by LWY
  // suspend_main 에서 카드에 보여줄 현재 내 rent 정보
  getCurrentRent()async{
    final response = await makeAuthenticatedRequest('http://127.0.0.1:8000/rent/current');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      currentRentInfo.value = Rent.fromMap(data['results']);
      update();
    } else {
      throw Exception("Failed to fetch user name: ${response.statusCode}");
    }
  }



}
