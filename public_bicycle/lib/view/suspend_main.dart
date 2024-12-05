﻿import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'suspend_detail.dart';
import '../vm/susp_map_handler.dart';
import 'coupon_page.dart';

class SuspendMain extends StatelessWidget {
  SuspendMain({super.key});
  final mapHandler = Get.put(SuspMapHandler());

  @override
  Widget build(BuildContext context) {
    // MediaQuery를 사용하여 화면 크기 얻기
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GetBuilder<SuspMapHandler>(
      builder: (controller) {
        return Scaffold(
          body: mapHandler.isRun
              ? Column(
                  children: [
                    SizedBox(
                      width: screenWidth,
                      height: screenHeight * 0.7,
                      child: flutterMap(),
                    ),
                    Container(
                      alignment: AlignmentDirectional.center,
                      height: screenHeight * 0.1,
                      child: Text(
                        mapHandler.mainText,
                      ),
                    ),
                    Container(
                      alignment: AlignmentDirectional.center,
                      height: screenHeight * 0.05,
                      child: const Text('연장가능여부 : O'),
                    ),
                    Container(
                      alignment: AlignmentDirectional.center,
                      height: screenHeight * 0.1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              if (mapHandler.mainIndex != null) {
                                Get.to(() => SuspendDetail(),
                                    arguments: mapHandler
                                        .stationList[mapHandler.mainIndex!]);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              side: BorderSide.none,
                            ),
                            child: const Text('대여예약하기'),
                          ),
                          SizedBox(
                            width: screenWidth * 0.2,
                          ),
                          OutlinedButton(
  onPressed: () {
    Get.to(() => CouponPage()); // 쿠폰 페이지로 이동
  },
  style: OutlinedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.green[600],
    side: BorderSide(color: Colors.green[600]!, width: 2),
  ),
  child: const Text('쿠폰확인하기')
),
                        ],
                      ),
                    ),
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget flutterMap() {
    return FlutterMap(
      mapController: mapHandler.mapController,
      options: MapOptions(
        initialCenter: mapHandler.startPoint,
        initialZoom: 16.0,
        minZoom: 14.0,
        maxZoom: 19.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        ),
        MarkerLayer(
          markers: mapHandler.markerList,
        ),
      ],
    );
  }
}