import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_bicycle/components/page_structure.dart';
import 'package:public_bicycle/components/user_dashboard_rent.dart';
import 'package:public_bicycle/components/user_dashboard_reservation.dart';
import 'package:public_bicycle/model/parking_station.dart';
import 'package:public_bicycle/view/login.dart';
import 'package:public_bicycle/view/sb/reservation.dart';
import 'package:public_bicycle/view/sb/suspend_main.dart';
import 'package:public_bicycle/vm/header_handler.dart';
import 'package:public_bicycle/vm/home_handler.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final homeHandler = Get.put(HomeHandler());
    return Scaffold(
      body: PageStructure(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: const BoxDecoration(
                  color: Colors.grey,
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
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          Obx(() => homeHandler.userState.value == 0
                              // 상태 없음
                              ? const SizedBox(
                                  child: Text('상태없음'),
                                )
                              : homeHandler.userState.value == 1
                                  // 예약
                                  ? UserDashboardReservation(
                                      stationName: homeHandler
                                          .userStateStationName.value,
                                      rentTime: homeHandler.userStateTime.value,
                                      rentMinute:
                                          homeHandler.userStateRentMinute.value,
                                      onPressed: () {
                                        homeHandler.reservationDelete();
                                      },
                                    )
                                  // 대여
                                  : UserDashboardRent(
                                      rentMinute: homeHandler
                                          .userStateRentMinute.value))
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
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Container(
                          width: Get.width * 0.8,
                          decoration: const BoxDecoration(
                            color: Colors.lightGreen,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("${snapshot.data![index][3][1]}"),
                                  ],
                                ),
                                Text(
                                    '현재 잔여 따릉이수: ${int.parse((snapshot.data![index][3][0]).toString()) < 0 ? '오류' : snapshot.data![index][3][0]} 대'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Obx(
                                      () => ElevatedButton(
                                        onPressed: int.parse((snapshot
                                                        .data![index][3][0])
                                                    .toString()) <
                                                0
                                            ? null
                                            : homeHandler.userState.value == 0
                                                ? () {
                                                    Get.find<HeaderHandler>()
                                                        .showMenuList
                                                        .value = false;
                                                    Get.find<HeaderHandler>()
                                                        .appbarSize
                                                        .value = kToolbarHeight;
                                                    homeHandler
                                                        .checkTokenState();
                                                    // print(homeHandler.tokenState);
                                                    if (homeHandler
                                                        .tokenState.value) {
                                                      Get.to(
                                                        () => Reservation(),
                                                        transition: Transition
                                                            .noTransition,
                                                        arguments: ParkingStation(
                                                            id: snapshot
                                                                    .data![index]
                                                                [0],
                                                            lat: snapshot
                                                                    .data![index]
                                                                [1],
                                                            lng: snapshot
                                                                    .data![index]
                                                                [2],
                                                            parkingCount: snapshot
                                                                    .data![index]
                                                                [3][0],
                                                            stationName: snapshot
                                                                    .data![index]
                                                                [3][1]),
                                                      );
                                                    } else {
                                                      Get.to(() => Login(),
                                                          transition: Transition
                                                              .noTransition);
                                                    }
                                                  }
                                                : null,
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 58, 134, 60),
                                            foregroundColor: Colors.white),
                                        child: const Text('예약하기'),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
