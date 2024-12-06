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
                child: const Text('예약 예상 시간'),
              ),
              Obx(() => SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: DropdownButtonFormField<String>(
                      // itemHeight: 10,
                      value: reservController.selectedItem.value,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          reservController.setSelected(newValue);
                          reservController.fetchpredBike(curstation.id, curstation.parkingCount);
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
                height: Get.height * 0.05,
                child:
                    Text('예측된 시간의 자전거 수 : ${reservController.predBike.value}'),
              ),
              Container(
                  alignment: Alignment.centerRight,
                  height: Get.height * 0.15,
                  child: OutlinedButton(
                      onPressed: () {
                        reservController.reserve(curstation.id);
                      },
                      style: OutlinedButton.styleFrom(),
                      child: const Text('예약하기'))),
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