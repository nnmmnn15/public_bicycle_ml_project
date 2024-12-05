import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_bicycle/components/page_structure.dart';
import 'package:public_bicycle/view/login.dart';
import 'package:public_bicycle/view/sb/reservation.dart';
import 'package:public_bicycle/view/sb/suspend_main.dart';
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
                decoration: BoxDecoration(
                  color: Colors.grey,
                ),
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Obx(
                      () => Column(
                        children: [
                          homeHandler.tokenState.value
                              ? Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'OOO님',
                                      style: TextStyle(fontSize: 20),
                                    ),

                                    // 대여 이전
                                    // Center(
                                    //   child: Text('대여 전'),
                                    // ),
                                    // 대여 이후
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Text(
                                        '남은 대여시간 00분',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('퍼센트바?'),
                                        ElevatedButton(
                                          onPressed: () {
                                            Get.to(() => SuspendMain(),
                                                transition:
                                                    Transition.noTransition);
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white),
                                          child: const Text('연장신청'),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : const Center(
                                  child: SizedBox(
                                    height: 150,
                                    child:
                                        Center(child: Text('로그인이 되어있지 않습니다')),
                                  ),
                                )
                        ],
                      ),
                    )),
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
                          decoration: BoxDecoration(
                            color: Colors.lightGreen,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                        "${snapshot.data![index].keys.toList()[0]}"),
                                    Text(
                                      '     예약가능',
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 0, 68, 255)),
                                    ),
                                  ],
                                ),
                                Text(
                                    '현재 잔여 따릉이수: ${snapshot.data![index].values.toList()[0]} 대'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        homeHandler.checkTokenState();
                                        // print(homeHandler.tokenState);
                                        if (homeHandler.tokenState.value) {
                                          Get.to(() => Reservation(),
                                              transition:
                                                  Transition.noTransition);
                                        } else {
                                          Get.to(() => Login(),
                                              transition:
                                                  Transition.noTransition);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 58, 134, 60),
                                          foregroundColor: Colors.white),
                                      child: const Text('예약하기'),
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
