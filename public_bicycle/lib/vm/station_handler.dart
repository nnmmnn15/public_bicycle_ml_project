import 'dart:convert';

import 'package:public_bicycle/model/station.dart';
import 'package:public_bicycle/vm/myapi.dart';
import 'package:get/get.dart';
class StationHandler extends Myapi{

  final stations = <Station>[].obs;
  String serverurl = '127.0.0.1';

  getAllStation() async {
    final response = await makeAuthenticatedRequest('$serverurl/station/station_all');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      
    } else {
      throw Exception("Failed to fetch user name: ${response.statusCode}");
    }
  }
}