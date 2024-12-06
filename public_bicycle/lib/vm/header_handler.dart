import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_bicycle/model/rent.dart';
import 'package:public_bicycle/vm/home_handler.dart';
// import 'package:http/http.dart' as http;

class HeaderHandler extends HomeHandler {
  final showMenuList = false.obs;
  var currentRentInfo = Rxn<Rent>();
  final appbarSize = kToolbarHeight.obs;

  @override
  void onInit() {
    super.onInit();
    checkTokenState();
    getCurrentRent();
    // showMenuList.value = false;
    // appbarSize.value = kToolbarHeight;
  }

  menuState() {
    showMenuList.value = !showMenuList.value;
  }

  // 메뉴의 수만큼 곱셈
  menuSize() {
    appbarSize.value = showMenuList.value ? kToolbarHeight * 4 : kToolbarHeight;
  }

  getCurrentRent() async {
    final response =
        await makeAuthenticatedRequest('http://127.0.0.1:8000/rent/current');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      currentRentInfo.value = Rent.fromMap(data['results']);
      print(currentRentInfo.value!.resume);
    } else {
      throw Exception("Failed to fetch user name: ${response.statusCode}");
    }
  }
  // getUserState() async {
  //   var url = Uri.parse('$serverurl/user/name');
  //   final response = await http.get(url);
  //   if (response.statusCode == 200) {
  //     var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
  //     final result = dataConvertedJSON['results'];
  //     print(result);
  //   }
  // }
}
