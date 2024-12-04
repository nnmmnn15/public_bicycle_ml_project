import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
class LoginHandler extends GetxController{

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final RxString accessToken = ''.obs;
  final serverurl = 'http://127.0.0.1:8000';
  
  login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$serverurl/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password}, // URL 인코딩된 데이터
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body); // JSON 응답 처리
      final accessToken = responseData['access_token'];
      await secureStorage.write(key: 'accessToken', value: accessToken);
    } else {
      final errorData = jsonDecode(response.body);
      Get.snackbar('로그인 실패', '로그인에 실패하였습니다. \n에러 : $errorData');
    }
  }


  signIn(String username, String password) async {
    var url = Uri.parse('$serverurl/check?id=');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        if (data == 1){
          return 1;
        }
        else{
          var url2 = Uri.parse('$serverurl/signin');
          var response2 = await http.get(url2);
          var data2 = json.decode(utf8.decode(response2.bodyBytes));
          return data2 == 1 ? 1:0;
          
        }
      } else {
        throw Exception("Failed to load species types");
      }
    } catch (e) {
      return false;
    }
    
  }

  Future<String?> getAccessToken() async {
  
    return await secureStorage.read(key: 'accessToken');
  }
}