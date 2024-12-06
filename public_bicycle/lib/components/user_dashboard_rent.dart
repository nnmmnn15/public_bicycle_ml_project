import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_bicycle/view/sb/suspend_main.dart';
import 'package:public_bicycle/vm/header_handler.dart';

class UserDashboardRent extends StatelessWidget {
  final int rentMinute;
  const UserDashboardRent({
    super.key,
    required this.rentMinute,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            '남은 대여시간 $rentMinute분',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('퍼센트바?'),
            ElevatedButton(
              onPressed: () {
                if (Get.find<HeaderHandler>().currentRentInfo.value!.resume >
                    0) {
                  Get.to(() => SuspendMain(),
                      transition: Transition.noTransition);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text('연장신청'),
            ),
          ],
        ),
      ],
    );
  }
}
