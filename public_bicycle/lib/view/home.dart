import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_bicycle/components/page_structure.dart';
import 'package:public_bicycle/components/user_dashboard_rent.dart';
import 'package:public_bicycle/components/user_dashboard_reservation.dart';
import 'package:public_bicycle/model/parking_station.dart';
import 'package:public_bicycle/view/login.dart';
import 'package:public_bicycle/view/sb/reservation.dart';
import 'package:public_bicycle/vm/header_handler.dart';
import 'package:public_bicycle/vm/home_handler.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final homeHandler = Get.put(HomeHandler());
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: PageStructure(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
               decoration: BoxDecoration(
                color: Colors.grey[200], // AppBar와 어울리는 밝은 녹색 배경
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4), // 살짝 아래쪽 그림자
                  ),
                ],
              ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => Text(
                              '${homeHandler.userName.value}님',
                             style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green, // 녹색 텍스트로 강조
                            ),
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height / 3.5,
                            decoration: BoxDecoration(
                              color: Colors.grey[200], // 연한 회색 배경
                            ),
                            child: Stack(
                              children: [
                                // 배경 아이콘
                                Center(
                                  child: Icon(
                                    Icons.directions_bike,
                                    color: Colors.grey.withOpacity(0.2), // 반투명 회색 아이콘
                                    size: 100,
                                  ),
                                ),
                                Obx(
                                  () => homeHandler.userState.value == 0
                                      ? const Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                               Text(
                                                '현재 예약하거나 대여하신 자전거가 없습니다.',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                               SizedBox(height: 10),
                                             
                                            ],
                                          ),
                                        )
                                      : homeHandler.userState.value == 1
                                          ? UserDashboardReservation(
                                              stationName: homeHandler.userStateStationName.value,
                                              rentTime: homeHandler.userStateTime.value,
                                              rentMinute: homeHandler.userStateRentMinute.value,
                                              onPressed: () {
                                                homeHandler.reservationDelete();
                                              },
                                            )
                                          : UserDashboardRent(
                                              rentMinute: homeHandler.userStateRentMinute.value,
                                              rentType: homeHandler.userBicycleType.value,
                                            ),
                                ),
                              ],
                            ),
                          )


                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            // 정류소 정보를 받아와야함
            FutureBuilder(
              future: homeHandler.parkingBike(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: List.generate(
                      snapshot.data!.length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                          width: Get.width * 0.85,
                          decoration: BoxDecoration(
                            color: Colors.lightGreen[100],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${snapshot.data![index][3][1]}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '현재 잔여 따릉이수: ${int.parse((snapshot.data![index][3][0]).toString()) < 0 ? '오류' : snapshot.data![index][3][0]} 대',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const Divider(height: 20, thickness: 1, color: Colors.grey),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    int.parse((snapshot.data![index][3][0]).toString()) <= 0
                                        ? SizedBox(
                                            height: MediaQuery.of(context).size.height / 28,
                                          )
                                        : ElevatedButton(
                                            onPressed: homeHandler.userState.value == 0
                                                ? () {
                                                    Get.find<HeaderHandler>()
                                                        .showMenuList
                                                        .value = false;
                                                    Get.find<HeaderHandler>()
                                                        .appbarSize
                                                        .value = kToolbarHeight;
                                                    homeHandler.checkTokenState();
                                                    if (homeHandler.tokenState.value) {
                                                      Get.to(
                                                        () => Reservation(),
                                                        transition: Transition.noTransition,
                                                        arguments: ParkingStation(
                                                          id: snapshot.data![index][0],
                                                          lat: snapshot.data![index][1],
                                                          lng: snapshot.data![index][2],
                                                          parkingCount: snapshot.data![index][3][0],
                                                          stationName: snapshot.data![index][3][1],
                                                        ),
                                                      );
                                                    } else {
                                                      Get.to(
                                                        () => Login(),
                                                        transition: Transition.noTransition,
                                                      );
                                                    }
                                                  }
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color.fromARGB(255, 58, 134, 60),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              '예약하기',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )

                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
