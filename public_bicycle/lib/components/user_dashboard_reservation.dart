import 'package:flutter/material.dart';

class UserDashboardReservation extends StatelessWidget {
  final String stationName;
  final String rentTime;
  final int rentMinute;
  final VoidCallback onPressed;
  const UserDashboardReservation({
    super.key,
    required this.stationName,
    required this.rentTime,
    required this.rentMinute,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            '예약 장소 $stationName',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            '예약 시간 $rentTime',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            '대여 시간 $rentMinute',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text('예약취소'),
            ),
          ],
        ),
      ],
    );
  }
}
