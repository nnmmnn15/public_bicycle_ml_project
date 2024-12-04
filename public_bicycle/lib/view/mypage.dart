import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'my_coupon.dart';
import '../vm/coupon_controller.dart';

class MyPage extends StatelessWidget {
  MyPage({super.key}) {
    Get.put(CouponController()); // 여기서 초기화
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(),
              const Divider(height: 32),
              _buildReservationSection(),
              const Divider(height: 32),
              _buildExtensionSection(),
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
            const Text(
              '프로필 정보',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.green[100],
                  child: const Icon(Icons.person, size: 30),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('홍길동', style: TextStyle(fontSize: 18)),
                    Text('user123@email.com'),
                    Text('010-1234-5678'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Chip(
              label: const Text('일반 회원'),
              backgroundColor: Colors.green[100],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '예약 현황',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('현재 예약'),
              subtitle: const Text('672.대광고등학교 - 15:00'),
              trailing: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[100],
                ),
                child: const Text('예약 취소'),
              ),
            ),
            const Divider(),
            const Text('예약 이력', style: TextStyle(fontSize: 16)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('예약 #${index + 1}'),
                  subtitle: const Text('2024-03-01 14:00'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtensionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '연장 이력',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('현재 이용 중'),
                  Text('자전거 번호: BK-001'),
                  Text('남은 시간: 1시간 30분'),
                  Text('연장 가능 여부: 가능'),
                ],
              ),
            ),
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
                const Text(
                  '쿠폰함',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
  onPressed: () => Get.to(() => MyCoupon()),
  // 또는 named 라우트 사용 시: Get.toNamed('/my-coupon'),
  style: TextButton.styleFrom(
    foregroundColor: Colors.green[600],
  ),
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
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              itemBuilder: (context, index) {
                return const ListTile(
                  leading: Icon(Icons.local_offer),
                  title: Text('KFC 40% 할인쿠폰'),
                  subtitle: Text('유효기간: 2024-03-31'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageStatsSection() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이용 통계',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('총 이용 횟수', style: TextStyle(color: Colors.grey)),
                    Text('15회', style: TextStyle(fontSize: 20)),
                  ],
                ),
                Column(
                  children: [
                    Text('총 이용 시간', style: TextStyle(color: Colors.grey)),
                    Text('25시간', style: TextStyle(fontSize: 20)),
                  ],
                ),
                Column(
                  children: [
                    Text('선호 대여소', style: TextStyle(color: Colors.grey)),
                    Text('대광고', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}