import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:public_bicycle/model/suspend_station.dart';
import 'package:public_bicycle/vm/susp_map_handler.dart';

class SuspendDetail extends StatelessWidget {
  SuspendDetail({super.key});

  final mapHandler = Get.put(SuspMapHandler());

  SuspendStation curstation = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SuspMapHandler>(
      builder: (controller) {
        return Scaffold(
          body: Column(
            children: [
              SizedBox(
                height: Get.height * 0.7,
                child: flutterMap()
              ),
              Text('정류장 이름: ${curstation.name}'),
              Container(
                alignment: AlignmentDirectional.center,
                height: Get.height * 0.05,
                child: const Text(
                  '현재 자전거 이름 : ???'
                ),
              ),
              Container(
                alignment: AlignmentDirectional.center,
                height: Get.height * 0.05,
                child: const Text(
                  '남은 시간 : XXX시간'
                ),
              ),
              Container(
                alignment: AlignmentDirectional.center,
                height: Get.height * 0.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: (){
                        // 
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        side: BorderSide.none
                      ),
                      child: const Text('예약하기')
                    ),
                    SizedBox(
                      width: Get.width * 0.2,
                    ),
                    OutlinedButton(
                      onPressed: (){
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green[600],
                        side: BorderSide(color: Colors.green[600]!, width: 2),
                      ),
                      child: const Text('뒤로가기')
                    ),
                  ],
                )
              ),

            ],
          ),
        );
      }
    );
  }


  Widget flutterMap() {
    // mapHandler.isRun = true;
    return FlutterMap(
      mapController: mapHandler.detailMapController,
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
          markers: [
            Marker(point: mapHandler.startPoint, child: const Icon(Icons.location_on, color: Colors.red,)),
            Marker(point: latlng.LatLng(curstation.lat, curstation.lng), child: Icon(Icons.location_on, color: Colors.green[300],) ),
          ]
        ),
      ],
    );
  }









}//End