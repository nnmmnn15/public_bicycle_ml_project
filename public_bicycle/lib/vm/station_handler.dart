import 'dart:convert';

import 'package:public_bicycle/model/station.dart';
import 'package:public_bicycle/vm/myapi.dart';
import 'package:get/get.dart';
class StationHandler extends Myapi{

  final stations = <Station>[].obs;
  String serverurl = 'http://127.0.0.1:8000';

  @override
  void onInit() async{
    super.onInit();
    await getAllStation();
  }

  getAllStation() async {
    try {
      final response = await makeAuthenticatedRequest('$serverurl/station/station_all');

      if (response.statusCode == 200) {
        // UTF-8로 디코딩 후 JSON 파싱
        final decoded = utf8.decode(response.bodyBytes);
        var data = jsonDecode(decoded);
        List temp = data['results'];
        List<Station> result = [];
        for (int i = 0; i < temp.length; i++){
          result.add(Station(
            id: temp[i]['id'], 
            dong: temp[i]['dong'], 
            address: temp[i]['address'],
            lat: temp[i]['lat'], 
            lng: temp[i]['lng'], 
            name: temp[i]['name']));
        }
        // 결과 출력
        // print(data);
        stations.value = result;
      } else {
        // HTTP 에러 처리
        throw Exception("Failed to fetch station data: ${response.statusCode}");
      }
    } catch (e) {
      // 에러 로그 출력
      print("Error fetching station data: $e");
      throw Exception("Failed to fetch station data");
    }
  }

}