import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart' as responsive;

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
