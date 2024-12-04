import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '/vm/myapi.dart';

class LoginHandler extends Myapi {
  final box = GetStorage();
  final RxString accessToken = ''.obs;
  final RxInt test = 0.obs;
  final serverurl = 'http://127.0.0.1:8000';

  // 로그인 처리
  Future<void> login(String id, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$serverurl/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': id, 'password': password},
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await secureStorage.write(key: 'accessToken', value: responseData['access_token']);
        await secureStorage.write(key: 'refreshToken', value: responseData['refresh_token']);
        box.write('id', id);
      } else {
        throw Exception(jsonDecode(response.body));
      }
    } catch (e) {
      print("Login error: $e");
      Get.snackbar('로그인 실패', '로그인에 실패하였습니다.');
    }
  }

  // 회원가입 체크
  Future<int> signIn(String username, String password) async {
    try {
      final checkResponse = await http.get(
        Uri.parse('$serverurl/check?id=$username'),
      );
      
      if (checkResponse.statusCode == 200) {
        final data = json.decode(utf8.decode(checkResponse.bodyBytes));
        if (data == 1) return 1;
        
        final signInResponse = await http.get(
          Uri.parse('$serverurl/signin?id=$username&password=$password'),
        );
        return json.decode(utf8.decode(signInResponse.bodyBytes)) == 1 ? 1 : 0;
      }
      return 0;
    } catch (e) {
      print("SignIn error: $e");
      return 0;
    }
  }

  // 사용자 정보 조회
  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    final token = await secureStorage.read(key: 'accessToken');
    if (token == null) throw Exception("Token not found");

    final response = await http.get(
      Uri.parse('$serverurl/user/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception("Failed to fetch user info");
  }

  // 예약 정보 조회
  Future<Map<String, dynamic>> getUserReservations(String userId) async {
    final token = await secureStorage.read(key: 'accessToken');
    if (token == null) throw Exception("Token not found");

    final response = await http.get(
      Uri.parse('$serverurl/user/$userId/reservations'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception("Failed to fetch reservations");
  }

  // 대여 이력 조회
  Future<Map<String, dynamic>> getRentHistory(String userId) async {
    final token = await secureStorage.read(key: 'accessToken');
    if (token == null) throw Exception("Token not found");

    final response = await http.get(
      Uri.parse('$serverurl/user/$userId/rent-history'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception("Failed to fetch rent history");
  }

  // 쿠폰 정보 조회
  Future<Map<String, dynamic>> getUserCoupons(String userId) async {
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
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception("Failed to fetch coupons");
  }

  // 이용 통계 조회
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    final token = await secureStorage.read(key: 'accessToken');
    if (token == null) throw Exception("Token not found");

    final response = await http.get(
      Uri.parse('$serverurl/user/$userId/stats'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception("Failed to fetch user stats");
  }
}