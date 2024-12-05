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
        final data = jsonDecode(decoded);

        // 결과 출력
        print(data['results']);
        return data['results'];
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