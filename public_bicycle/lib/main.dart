import 'package:flutter/material.dart';
import 'view/coupon_page.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'view/my_coupon.dart';
import 'view/sb/suspend_main.dart';
import 'view/sb/suspend_detail.dart';
import 'model/suspend_station.dart';
import 'view/sb/reservation.dart';
import 'package:get/get.dart';
import 'view/mypage.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: (context, child) =>
          ResponsiveBreakpoints.builder(child: child!, breakpoints: [
        const Breakpoint(start: 0, end: 450, name: MOBILE),
        const Breakpoint(start: 451, end: 800, name: TABLET),
        const Breakpoint(start: 801, end: 1920, name: DESKTOP),
        const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
      ]),
      title: '따릉이 플러스',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // 테스트를 위해 초기 화면을 쿠폰 페이지로 설정
      home:  MyPage(),
    );
  }
}