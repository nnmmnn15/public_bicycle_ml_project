import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_bicycle/view/sb/suspend_main.dart';
import 'package:public_bicycle/vm/header_handler.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class UserDashboardRent extends StatelessWidget {
  final int rentMinute;
  final int rentType;
  const UserDashboardRent({
    super.key,
    required this.rentMinute,
    required this.rentType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: MediaQuery.of(context).size.height/6,
  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  padding: const EdgeInsets.all(16),
  // decoration: BoxDecoration(
  //   color: Colors.green[50], // AppBar와 어울리는 밝은 녹색 배경
  //   borderRadius: BorderRadius.circular(10),
  //   boxShadow: [
  //     BoxShadow(
  //       color: Colors.black.withOpacity(0.1),
  //       blurRadius: 8,
  //       offset: const Offset(0, 4), // 살짝 아래쪽 그림자
  //     ),
  //   ],
  // ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 10), // 회원님과 다음 요소 간 간격
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '남은 대여시간',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold, // 텍스트를 진하게
                color: Colors.green, // 녹색 텍스트로 강조
              ),
            ),
            Text(
              '$rentMinute분',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      const Divider(
        color: Colors.grey, // 경계선 색상
        thickness: 1, // 경계선 두께
      ),
      const SizedBox(height: 10), // 여백 추가
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width/4,
            height: MediaQuery.of(context).size.height/9,
            child: SfRadialGauge(
  axes: <RadialAxis>[
    RadialAxis(
      startAngle: 180, // 반원 시작 각도
      endAngle: 0, // 반원 끝 각도
      minimum: 0,
      maximum: (rentType > 0 ? rentType : 60).toDouble(), // 기본값 60
      showLabels: false, // 숫자 숨기기
      showTicks: false, // 축 틱 숨기기
      axisLineStyle: const AxisLineStyle(
        thickness: 0.1, // 축 두께
        thicknessUnit: GaugeSizeUnit.factor, // 두께 단위 설정
      ),
      pointers: <GaugePointer>[
        NeedlePointer(
          value: rentMinute.toDouble(), // 현재 값
          enableAnimation: true, // 애니메이션 활성화
          animationDuration: 1200, // 애니메이션 지속 시간
          needleColor: Colors.green, // 포인터 색상
          needleLength: 0.8, // 반경 비율로 길이 설정
          knobStyle: KnobStyle(
            knobRadius: 0.05, // 중심 노브 크기
            color: Colors.green[600], // 중심 노브 색상
          ),
        ),
      ],
    ),
  ],
),

          )
,
          ElevatedButton(
            onPressed: () {
              if (Get.find<HeaderHandler>().currentRentInfo.value!.resume > 0) {
                Get.to(() => SuspendMain(), transition: Transition.noTransition);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // 버튼 색상
              foregroundColor: Colors.white, // 텍스트 색상
              elevation: 2, // 버튼에 그림자 효과 추가
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              '연장신청',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ],
  ),
);


  }
}
