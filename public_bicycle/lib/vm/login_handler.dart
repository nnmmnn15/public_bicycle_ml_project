import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:public_bicycle/view/home.dart';
import 'package:public_bicycle/vm/myapi.dart';

class LoginHandler extends Myapi {
  final box = GetStorage();
  final RxString accessToken = ''.obs;
  final RxInt test = 0.obs;
  final serverurl =
      // 'http://10.0.2.2';
      'http://127.0.0.1:8000';

  hasTokken() async {
    final token = await secureStorage.read(key: 'refreshToken');
    if (token != null) {
      Get.to(() => const Home(), transition: Transition.noTransition);
    }
  }

  Future<void> login(String id, String password) async {
    // print('id: $id');
    // print('Password: $password');
    try {
      final response = await http.post(
        Uri.parse('$serverurl/auth/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': id, 'password': password}, // URL 인코딩된 데이터
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body); // JSON 응답 처리
        // AccessToken 및 RefreshToken 저장
        final accessToken = responseData['access_token'];
        final refreshToken = responseData['refresh_token'];

        await secureStorage.write(key: 'accessToken', value: accessToken);
        await secureStorage.write(key: 'refreshToken', value: refreshToken);
        box.write('id', id);
        // print("Tokens saved successfully.");
        // String? atoken = await secureStorage.read(key: 'accessToken');
        // String? rtoken = await secureStorage.read(key: 'refreshToken');
        // print('token : $atoken');
        // print('token : $rtoken');
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar('로그인 실패', '로그인에 실패하였습니다. \n에러 : $errorData');
      }
    } catch (e, stackTrace) {
      print("Error occurred: $e");
      print("Stack trace: $stackTrace");
      Get.snackbar('오류', '로그인 요청 중 오류가 발생하였습니다.');
    }
  }

  signIn(String username, String password) async {
    var url = Uri.parse('$serverurl/check?id=');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        if (data == 1) {
          return 1;
        } else {
          var url2 = Uri.parse('$serverurl/signin');
          var response2 = await http.get(url2);
          var data2 = json.decode(utf8.decode(response2.bodyBytes));
          return data2 == 1 ? 1 : 0;
        }
      } else {
        throw Exception("Failed to load species types");
      }
    } catch (e) {
      return false;
    }
  }

  fetchUserName() async {
    final token = await secureStorage.read(key: 'accessToken');
    if (token == null) {
      throw Exception("Access token not found");
    }
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/user/name'),
      headers: {
        'Authorization': 'Bearer $token', // JWT를 Authorization 헤더에 추가
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      test.value = data['results'];
      update();
    } else {
      throw Exception("Failed to fetch user name: ${response.statusCode}");
    }
  }

  jwtTokenTest() async {
    final response =
        await makeAuthenticatedRequest('$serverurl/login/user/name');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      test.value = data['results'];
    } else {
      throw Exception("Failed to fetch user name: ${response.statusCode}");
    }
  }

  // 사용자 정보 조회
  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    final response =
        await makeAuthenticatedRequest('$serverurl/login/user/$userId');
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception("Failed to fetch user info");
  }

  // 예약 정보 조회
  Future<Map<String, dynamic>> getUserReservations(String userId) async {
    final response = await makeAuthenticatedRequest(
        '$serverurl/login/user/$userId/reservations');
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception("Failed to fetch reservations");
  }

  // 대여 이력 조회
  Future<Map<String, dynamic>> getRentHistory(String userId) async {
    final response = await makeAuthenticatedRequest(
        '$serverurl/login/user/$userId/rent-history');
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception("Failed to fetch rent history");
  }

  // 쿠폰 정보 조회
  Future<Map<String, dynamic>> getUserCoupons(String userId) async {
    final response =
        await makeAuthenticatedRequest('$serverurl/login/user/$userId/coupons');
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception("Failed to fetch coupons");
  }


  // 예약 취소 
  Future<bool> cancelReservation(int reservationId) async {
  final token = await secureStorage.read(key: 'accessToken');
  if (token == null) throw Exception("Token not found");

  final response = await http.delete(
    Uri.parse('$serverurl/reservation/$reservationId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  return response.statusCode == 200;
}


Future<Map<String, dynamic>> getCouponDetails(String couponId) async {
  try {
    final token = await secureStorage.read(key: 'accessToken');
    if (token == null) throw Exception("Token not found");

    final response = await http.get(
      Uri.parse('$serverurl/coupons/detail/$couponId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Failed to load coupon details');
  } catch (e) {
    print('Error getting coupon details: $e');
    throw Exception('쿠폰 정보를 불러오는데 실패했습니다');
  }
}

Future<List<Map<String, dynamic>>> loadUserCoupons(String userId) async {
  try {
    final token = await secureStorage.read(key: 'accessToken');
    if (token == null) throw Exception("Token not found");

    final response = await http.get(
      Uri.parse('$serverurl/user/$userId/coupons'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(data['coupons']);
    }
    return [];
  } catch (e) {
    print('Error loading user coupons: $e');
    return [];
  }
}


  // 이용 통계 조회
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    final response =
        await makeAuthenticatedRequest('$serverurl/login/user/$userId/stats');
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception("Failed to fetch user stats");
  }
}
