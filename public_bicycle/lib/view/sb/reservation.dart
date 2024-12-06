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
        body: Stack(
          children: [
            // 지도 배경
            SizedBox(
              height: Get.height,
              width: Get.width,
              child: flutterMap(),
            ),
            // 고정된 UI 컨테이너
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Material(
                elevation: 10,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${curstation.id} ${curstation.stationName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // 나머지 UI
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 예약 예상 시간
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '예약 예상 시간',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // 드롭다운
                            Obx(() => SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4, // 전체 크기 지정
                                child: DropdownButtonFormField<String>(
                                  isDense: true, // 아이템 간격을 줄임
                                  isExpanded: true, // 드롭다운이 부모 크기에 맞게 확장됨
                                  value: reservController.selectedItem.value,
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      reservController.setSelected(newValue);
                                      reservController.fetchpredBike(
                                        curstation.id,
                                        curstation.parkingCount,
                                      );
                                    }
                                  },
                                  items: reservController.dropdownItems
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                          fontSize: 14, // 글씨 크기 증가
                                          color: Colors.green, // 글씨 색상을 초록색으로 변경
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10), // 둥근 테두리
                                      borderSide: const BorderSide(
                                        color: Colors.green, // 테두리 색상을 초록색으로 변경
                                        width: 2, // 테두리 두께 증가
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Colors.green, // 활성화 상태 초록색 테두리
                                        width: 2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Colors.greenAccent, // 포커스 상태의 테두리 색상 변경
                                        width: 2.5, // 포커스 상태의 두께 증가
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.green[50], // 배경색을 옅은 초록색으로 변경
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8, // 패딩 조정
                                    ),
                                  ),
                                  dropdownColor: Colors.green[50], // 드롭다운 메뉴 배경색 변경
                                  alignment: Alignment.centerLeft, // 드롭다운 메뉴 정렬
                                ),
                              ),

                            ),
                            const SizedBox(height: 10),
                            // 현재 남아있는 자전거 수
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '현재 남아있는 자전거 수 : ${curstation.parkingCount}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green[800],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // 예측된 시간의 자전거 수
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '예측된 시간의 자전거 수 : ${reservController.predBike.value}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green[800],
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            // 예약 버튼
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton(
                                onPressed: () {
                                  reservController.reserve(curstation.id);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.green),
                                ),
                                child: const Text('예약하기'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget flutterMap() {
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
}
