import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_bicycle/vm/home_handler.dart';
// import 'package:http/http.dart' as http;

class HeaderHandler extends HomeHandler {
  final showMenuList = false.obs;

  final appbarSize = kToolbarHeight.obs;

  @override
  void onInit() {
    super.onInit();
    checkTokenState();
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
