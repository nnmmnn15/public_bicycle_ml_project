import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:public_bicycle/components/page_structure.dart';
import 'package:public_bicycle/model/parking_station.dart';
import 'package:public_bicycle/vm/reservation_controller.dart';

class Reservation extends StatelessWidget {
  Reservation({super.key});

  final reservController = Get.put(ReservationController());

  final ParkingStation curstation = Get.arguments;





  @override
  Widget build(BuildContext context) {

    return GetBuilder<ReservationController>(builder: (controller) {
      return Scaffold(
        body: PageStructure(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Get.height * 0.5, child: flutterMap()),
              Container(
                alignment: Alignment.centerLeft,
                height: Get.height * 0.05,
                child: Text('${curstation.id} ${curstation.stationName}'),
              ),
              Container(
                alignment: Alignment.bottomLeft,
                height: Get.height * 0.05,
                child: const Text('예약 시간을 골라주세요!'),
              ),
              Obx(() => SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: DropdownButtonFormField<String>(
                      // itemHeight: 10,
                      value: reservController.selectedItem.value,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          reservController.setSelected(newValue);
                          if (reservController.selectedItem != reservController.nowvalue){
                            reservController.fetchpredBike(curstation.id, curstation.parkingCount);
                          }
                        }
                      },
                      items: reservController.dropdownItems
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      ),
                    ),
                  )),
              Container(
                alignment: Alignment.centerLeft,
                height: Get.height * 0.05,
                child:
                    Text('현재 남아있는 자전거 수 : ${curstation.parkingCount}'),
              ),
              Container(
                alignment: Alignment.centerLeft,
                height: Get.height * 0.10,
                child:
                    Obx(
                      () {
                        return 
                        reservController.selectedItem.value == reservController.nowvalue
                        ? const Text('예약시간을 골라주세요!')
                        : reservController.isfetching.value
                          ?const Text('데이터를 계산중입니다....')
                          :Text('예측된 시간의 자전거 수 : \n 최소 : ${reservController.maxBike.value} \n 최대: ${reservController.minBike.value}')
                          
                        ;
                      }
                    ),
              ),
              SizedBox(
                height: Get.height * 0.10,
                child: Row(
                  children: [
                      OutlinedButton(
                        onPressed: () {
                          Get.back();
                        },
                        style: OutlinedButton.styleFrom(),
                        child: const Text('뒤로가기')
                      ),
                      SizedBox(width: Get.width * 0.8 -100,),
                      Obx(
                        (){
                          return Visibility(
                            visible: reservController.selectedItem.value != reservController.nowvalue,
                            child: Column(
                              children: [
                                Text('${reservController.selectedItem.value} 시간대로 예약하시겠습니까 ?'),
                                OutlinedButton(
                                  onPressed: () {
                                    reservController.reserve(curstation.id);
                                    Get.back();
                                  },
                                  style: OutlinedButton.styleFrom(),
                                  child: const Text('예약하기')
                                ),
                              ],
                            ),
                          );
                        }
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: Get.height * 0.05,
              )
            ],
          ),
        ),
      );
    });
  }

  Widget flutterMap() {
    // mapHandler.isRun = true;
    return FlutterMap(
      mapController: reservController.mapController,
      options: MapOptions(
        initialCenter: latlng.LatLng(curstation.lat, curstation.lng),
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
        MarkerLayer(markers: [
          Marker(
              point: latlng.LatLng(curstation.lat, curstation.lng),
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
              )),
        ]),
      ],
    );
  }
}//End