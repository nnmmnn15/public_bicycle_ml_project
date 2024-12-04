import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:public_bicycle/view/sb/suspend_detail.dart';
import 'package:public_bicycle/vm/susp_map_handler.dart';

class SuspendMain extends StatelessWidget {
  SuspendMain({super.key});
  final mapHandler = Get.put(SuspMapHandler());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SuspMapHandler>(builder: (controller) {
      return Scaffold(
          body: mapHandler.isRun
              ? Column(
                  children: [
                    SizedBox(
                        width: Get.width,
                        height: Get.height * 0.7,
                        child: flutterMap()),
                    Container(
                      alignment: AlignmentDirectional.center,
                      height: Get.height * 0.1,
                      child: Text(
                        mapHandler.mainText,
                      ),
                    ),
                    Container(
                      alignment: AlignmentDirectional.center,
                      height: Get.height * 0.05,
                      child: const Text('연장가능여부 : O'),
                    ),
                    Container(
                        alignment: AlignmentDirectional.center,
                        height: Get.height * 0.1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton(
                                onPressed: () {
                                  if (mapHandler.mainIndex != null) {
                                    Get.to(() => SuspendDetail(),
                                        arguments: mapHandler.stationList[
                                            mapHandler.mainIndex!]);
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.green[600],
                                    foregroundColor: Colors.white,
                                    side: BorderSide.none),
                                child: const Text('대여예약하기')),
                            SizedBox(
                              width: Get.width * 0.2,
                            ),
                            OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.green[600],
                                  side: BorderSide(
                                      color: Colors.green[600]!, width: 2),
                                ),
                                child: const Text('쿠폰확인하기')),
                          ],
                        )),
                  ],
                )
              : const Center(child: CircularProgressIndicator()));
    });
  }

  Widget flutterMap() {
    // mapHandler.isRun = true;
    return FlutterMap(
      mapController: mapHandler.mapController,
      options: MapOptions(
        initialCenter: mapHandler.startPoint,
        initialZoom: 16.0,
        minZoom: 14.0,
        maxZoom: 19.0,
        //// 회전안됑
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onTap: (tapPosition, point) {
          print(point);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        ),
        MarkerLayer(markers: mapHandler.markerList),
        CircleLayer(
          circles: [
            CircleMarker(
              point: mapHandler.startPoint,
              radius: 25, // 반경 (미터 단위)
              useRadiusInMeter: true,
              color: Colors.blue.withOpacity(0.3), // 원 내부 색상
              borderColor: Colors.blue, // 원 테두리 색상
              borderStrokeWidth: 2, // 테두리 두께
            ),
          ],
        )
      ],
    );
  }
}//End