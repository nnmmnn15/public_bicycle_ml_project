import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'my_coupon.dart';
import '../vm/login_handler.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final loginHandler = Get.find<LoginHandler>();
  Map<String, dynamic>? userData;
  List<List<dynamic>> reservations = [];
  List<List<dynamic>> rentHistory = [];
  List<dynamic>? stats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      final token = await loginHandler.secureStorage.read(key: 'accessToken');
      final userId = loginHandler.box.read('id');

      if (token == null || userId == null) {
        print('Error: Token or UserId is null');
        Get.snackbar('오류', '로그인이 필요합니다');
        return;
      }

      try {
        final userInfo = await loginHandler.getUserInfo(userId);
        userData = userInfo['user_info'];
      } catch (e) {
        print('Error loading user info: $e');
      }

      try {
        final reservationData = await loginHandler.getUserReservations(userId);
        if (reservationData['reservations'] is List) {
          reservations = List<List<dynamic>>.from(reservationData['reservations']);
        }
      } catch (e) {
        print('Error loading reservations: $e');
      }

      try {
        final rentData = await loginHandler.getRentHistory(userId);
        if (rentData['rent_history'] is List) {
          rentHistory = List<List<dynamic>>.from(rentData['rent_history']);
        }
      } catch (e) {
        print('Error loading rent history: $e');
      }

      try {
        final statsData = await loginHandler.getUserStats(userId);
        stats = statsData['stats'];
      } catch (e) {
        print('Error loading stats: $e');
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('General error in _loadAllData: $e');
      Get.snackbar('오류', '데이터 로딩 중 오류가 발생했습니다');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(),
              const Divider(height: 32),
              _buildReservationSection(),
              const Divider(height: 32),
              _buildRentSection(),
              const Divider(height: 32),
              _buildCouponSection(),
              const Divider(height: 32),
              _buildUsageStatsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('프로필 정보', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.green[100],
                  child: const Icon(Icons.person, size: 30),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userData?['name'] ?? '', style: const TextStyle(fontSize: 18)),
                    Text('ID: ${userData?['id'] ?? ''}'),
                    Text('나이: ${userData?['age'] ?? ''}세'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

Widget _buildReservationSection() {
  DateTime? parseReservationDate(String input) {
    try {
      // 입력 문자열에서 불필요한 부분 제거
      String cleanedInput = input.replaceAll(RegExp(r'\s+:.*$'), '');
      return DateTime.parse(cleanedInput);
    } catch (e) {
      print('Date parsing error: $e');
      return null;
    }
  }

  String formatReservationDate(DateTime dateTime) {
    return '${dateTime.year}-'
           '${dateTime.month.toString().padLeft(2, '0')}-'
           '${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // 현재 시간 이후의 예약만 필터링
  final futureReservations = reservations.where((reservation) {
    final dateTime = parseReservationDate(reservation[5].toString());
    return dateTime != null && dateTime.isAfter(DateTime.now());
  }).toList();

  // 예약 시간순으로 정렬
  if (futureReservations.isNotEmpty) {
    futureReservations.sort((a, b) {
      final dateTimeA = parseReservationDate(a[5].toString()) ?? DateTime.now();
      final dateTimeB = parseReservationDate(b[5].toString()) ?? DateTime.now();
      return dateTimeA.compareTo(dateTimeB);
    });
  }

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('예약 현황', 
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (futureReservations.isNotEmpty)
            ListTile(
              title: Text('정류소: ${futureReservations[0][6]}'),
              subtitle: Text(
                '예약 일시: ${formatReservationDate(parseReservationDate(futureReservations[0][5].toString())!)}\n'
                '예약 시간: ${futureReservations[0][4]}분',
              ),
              trailing: ElevatedButton(
                onPressed: () => loginHandler.cancelReservation(futureReservations[0][0]),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[100],
                ),
                child: const Text('예약 취소'),
              ),
            )
          else
            const Text('현재 예약 내역이 없습니다.'),
        ],
      ),
    ),
  );
}


  Widget _buildRentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('대여 이력', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (rentHistory.isNotEmpty)
              ...rentHistory.map((rent) => ListTile(
                    title: Text('자전거 번호: ${rent[1]}'),
                    subtitle: Text('대여 시간: ${rent[3]}'),
                  ))
            else
              const Text('대여 이력이 없습니다.'),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('쿠폰함', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => Get.to(() => MyCoupon()),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('전체보기'),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageStatsSection() {
    final totalRides = stats?[0] ?? 0;
    final totalMinutes = stats?[1] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('이용 통계', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('총 이용 횟수', '$totalRides회'),
                _buildStatItem('총 이용 시간', '${totalMinutes ~/ 60}시간'),
                _buildStatItem('선호 대여소', '대광고'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 20)),
      ],
    );
  }
}