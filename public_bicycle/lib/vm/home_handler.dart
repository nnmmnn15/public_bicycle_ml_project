import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:public_bicycle/vm/myapi.dart';

class HomeHandler extends Myapi {
  final serverurl = 'http://127.0.0.1:8000';
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final tokenState = false.obs;

  String userName = '';

  @override
  void onInit() {
    super.onInit();
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
    final response = await makeAuthenticatedRequest('$serverurl/user/name');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
    } else {
      throw Exception("Failed to fetch user name: ${response.statusCode}");
    }
  }
}
