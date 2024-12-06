import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:public_bicycle/model/station.dart';
import 'package:public_bicycle/view/sb/suspend_detail.dart';
import 'package:public_bicycle/vm/station_handler.dart';
import 'package:public_bicycle/vm/susp_map_handler.dart';
import 'package:public_bicycle/view/coupon_page.dart';

class SuspendMain extends StatelessWidget {
  SuspendMain({super.key});
  final mapHandler = Get.put(SuspMapHandler());
  final StationHandler stationHandler = Get.put(StationHandler());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SuspMapHandler>(builder: (controller) {
      return FutureBuilder(
        future: stationHandler.getAllStation(),
        builder: (context, snapshot) => Scaffold(
            body: mapHandler.isRun.value
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
                          mapHandler.mainText.value,
                        ),
                      ),
                      Container(
                        alignment: AlignmentDirectional.center,
                        height: Get.height * 0.05,
                        child: Text(
                            '연장가능여부 : ${mapHandler.currentRentInfo.value!.resume}'),
                      ),
                      Container(
                          alignment: AlignmentDirectional.center,
                          height: Get.height * 0.1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton(
                                  onPressed: () async {
                                    await mapHandler.getCurrentLocation();
                                    // if (mapHandler.mainIndex != null) {
                                    await Get.defaultDialog(
                                      title: '연장하기',
                                      middleText: '연장하시겠습니까?',
                                      onConfirm: () async {
                                        var result = await mapHandler
                                            .callProlongationAPI(
                                                mapHandler.curLatData,
                                                mapHandler.curLngData);
                                        print(result.runtimeType);
                                        if (result == 1) {
                                          Get.defaultDialog(
                                            title: '연장 성공',
                                            middleText: '연장에 성공하였습니다.',
                                            onConfirm: () => Get.back(),
                                          );
                                        }
                                        Get.back();
                                      },
                                    );
                                    // await mapHandler.callavaAPI(mapHandler.curLatData, mapHandler.curLngData!);
                                    // Get.to(() => SuspendDetail(),
                                    //     arguments: mapHandler.stationList[
                                    //         mapHandler.mainIndex!]);
                                  },
                                  style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.green[600],
                                      foregroundColor: Colors.white,
                                      side: BorderSide.none),
                                  child: const Text('연장하기')),
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
                : const Center(child: CircularProgressIndicator())),
      );
    });
  }

  Widget flutterMap() {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapHandler.mapController,
          options: MapOptions(
            initialCenter: mapHandler.startPoint,
            initialZoom: 16.0,
            minZoom: 14.0,
            maxZoom: 19.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onTap: (tapPosition, point) async {
              await await mapHandler
                  .showFloatingContainer(point); // 터치된 위치로 컨테이너 표시
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
                  radius: 25,
                  useRadiusInMeter: true,
                  color: Colors.blue.withOpacity(0.3),
                  borderColor: Colors.blue,
                  borderStrokeWidth: 2,
                ),
              ],
            ),
          ],
        ),
        GetBuilder<SuspMapHandler>(
          builder: (controller) {
            return controller.isContainerVisible
                ? Positioned(
                    top: 100,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Selected Location",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                              "Latitude: ${controller.selectedPoint?.latitude ?? 'N/A'}"),
                          Text(
                              "Longitude: ${controller.selectedPoint?.longitude ?? 'N/A'}"),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  controller.hideFloatingContainer();
                                },
                                child: const Text("Confirm"),
                              ),
                              const SizedBox(width: 20),
                              OutlinedButton(
                                onPressed: () {
                                  controller.hideFloatingContainer();
                                },
                                child: const Text("Cancel"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}//End