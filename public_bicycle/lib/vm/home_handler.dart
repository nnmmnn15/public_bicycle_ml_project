import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:public_bicycle/vm/myapi.dart';

class HomeHandler extends Myapi {
  final serverurl = 'http://127.0.0.1:8000';
  // final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final tokenState = false.obs;

  final userName = ''.obs;

  /// 유저 상태
  final userState = 0.obs;

  /// 예약시간
  final userStateTime = ''.obs;

  /// 예약번호
  final reservationNum = 0.obs;

  /// 예약장소 이름
  final userStateStationName = ''.obs;

  /// 대여 남은시간, 대여시간
  final userStateRentMinute = 0.obs;
  final userBicycleType = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getUserName();
    stateUpdate();
    checkTokenState();
  }

  checkTokenState() async {
    // print(await secureStorage.read(key: 'refreshToken'));
    if (await secureStorage.read(key: 'refreshToken') == null) {
      tokenState.value = false;
    } else {
      tokenState.value = true;
    }
  }

  Future<List> parkingBike() async {
    var url = Uri.parse('$serverurl/station/station_parking_bike');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      final result = dataConvertedJSON['results'];
      return result;
    } else {
      return [];
    }
  }

  Future getUserName() async {
    final response =
        await makeAuthenticatedRequest('http://127.0.0.1:8000/login/user/name');
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      userName.value = data['results'];
    } else {
      throw Exception("Failed to fetch user name: ${response.statusCode}");
    }
  }

  // 유저 대여, 예약 상태 호출
  getState() async {
    final response = await makeAuthenticatedRequest(
        'http://127.0.0.1:8000/login/action_state');
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final result = data['results'];
      return result;
    } else {
      throw Exception("Failed to fetch user name: ${response.statusCode}");
    }
  }

  // 유저 대여, 예약 상태 업데이트
  stateUpdate() async {
    var stateUser = await getState();
    userState.value = stateUser[0]['state'];
    if (userState.value == 0) {
      //
    } else if (userState.value == 1) {
      // 예약 상태
      userStateTime.value = stateUser[1]['value'][0];
      userStateRentMinute.value = int.parse(stateUser[1]['value'][1]);
      userStateStationName.value = stateUser[1]['value'][2];
      reservationNum.value = stateUser[1]['value'][3];
      userBicycleType.value = stateUser[1]['value'][4];
    } else if (userState.value == 2) {
      // 빌린 상태
      userStateRentMinute.value = stateUser[1]['value'];
      
    }
    // 10초 후에 stateUpdate 함수 실행
    Future.delayed(const Duration(seconds: 2), () async {
      if (await secureStorage.read(key: 'refreshToken') != null) {
        stateUpdate();
      }
    });
  }

  // 유저 예약 취소
  reservationDelete() async {
    var url = Uri.parse(
        '$serverurl/reserve/delete_reservation?reservation_id=${reservationNum.value}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      final result = dataConvertedJSON['results'];
      if (result) {
        stateUpdate();
      }
    }
  }
}
