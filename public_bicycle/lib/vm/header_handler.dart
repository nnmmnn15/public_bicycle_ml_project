import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HeaderHandler extends GetxController {
  final showMenuList = false.obs;

  final appbarSize = kToolbarHeight.obs;

  menuState() {
    showMenuList.value = !showMenuList.value;
  }

  // 메뉴의 수만큼 곱셈
  menuSize() {
    appbarSize.value = showMenuList.value ? kToolbarHeight * 4 : kToolbarHeight;
  }
}
