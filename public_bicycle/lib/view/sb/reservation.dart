import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng ;
import 'package:public_bicycle/vm/reservation_controller.dart';

class Reservation extends StatelessWidget {
  Reservation({super.key});

  final reservController = Get.put(ReservationController());

  final double curLat = 37.4948116;
  final double curLng = 127.0301043;
  final String station_num = '651';
  final String name = '대광고등학교';


  @override
  Widget build(BuildContext context) {




    return GetBuilder<ReservationController>(
      builder: (controller) {
        return Scaffold(
          body: Column(
            children: [
              SizedBox(height: Get.height * 0.5, child: flutterMap()),
              Obx(() => SizedBox(
                width: Get.width * 0.4,
                child: DropdownButtonFormField<String>(
                  value: controller.selectedItem.value,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.setSelected(newValue);
                    }
                  },
                  items: controller.items.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                ),
              ))
            ],
          ),
        );
      }
    );
  }

  Widget flutterMap() {
    // mapHandler.isRun = true;
    return FlutterMap(
      mapController: reservController.mapController,
      options: MapOptions(
        initialCenter: latlng.LatLng(curLat, curLng),
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
            Marker(point: latlng.LatLng(curLat, curLng), child: const Icon(Icons.location_on, color: Colors.red,)),
          ]
        ),
      ],
    );
  }










}//End