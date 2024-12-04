import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/page_structure.dart';
import 'sb/reservation.dart';
import 'sb/suspend_main.dart';
import '../vm/login_handler.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    final loginHandler = Get.put(LoginHandler());
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'OOO님',
                        style: TextStyle(fontSize: 20),
                      ),

                      // 대여 이전
                      // Center(
                      //   child: Text('대여 전'),
                      // ),
                      // 대여 이후
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          '남은 대여시간 00분',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('퍼센트바?'),
                          ElevatedButton(
                            onPressed: () {
                              Get.to(() => SuspendMain(),
                                  transition: Transition.noTransition);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white),
                            child: const Text('연장신청'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 정류소 정보를 받아와야함
            Column(
              children: List.generate(
                2,
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
                          const Row(
                            children: [
                              Text('정류소 명'),
                              Text(
                                '     예약가능',
                                style: TextStyle(
                                    color:
                                        Color.fromARGB(255, 0, 68, 255)),
                              ),
                            ],
                          ),
                          const Text('현재 잔여 따릉이수: 00 대'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Get.to(() => Reservation(),
                                      transition: Transition.noTransition);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 58, 134, 60),
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
            ),
          ],
        ),
      ),
    );
  }
}
