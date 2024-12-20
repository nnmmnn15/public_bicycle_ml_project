import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


class TokenAccess extends GetxController{
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final currentToken = ''.obs;
  
  printRefreshToken() async{
    currentToken.value = getRefreshToken();
    update();
  }

  getAccessToken() async {
    return await secureStorage.read(key: 'accessToken');
  }

  getRefreshToken() async {
    return await secureStorage.read(key: 'refreshToken');
  }

  saveAccessToken(String token) async {
    await secureStorage.write(key: 'accessToken', value: token);
  }

  saveRefreshToken(String token) async {
    await secureStorage.write(key: 'refreshToken', value: token);
  }

  deleteTokens() async {
    await secureStorage.delete(key: 'accessToken');
    await secureStorage.delete(key: 'refreshToken');
  }

  Future<bool> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/auth/token/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      print('HTTP Response: ${response.statusCode} ${response.body}'); // 디버깅 로그 추가

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access_token'];
        await saveAccessToken(newAccessToken);
        return true;
      } else {
        print('Failed to refresh token. Server response: ${response.body}');
        return false;
      }
    } catch (e) {
      print("Failed to refresh token: $e");
      return false;
    }
  }
}