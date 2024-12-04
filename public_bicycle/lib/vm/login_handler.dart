import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:public_bicycle/vm/myapi.dart';

class LoginHandler extends Myapi{

  final RxString accessToken = ''.obs;
  final RxInt test = 0.obs;
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
    final response = await makeAuthenticatedRequest('http://127.0.0.1:8000/user/name');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      test.value = data['results'];
    } else {
      throw Exception("Failed to fetch user name: ${response.statusCode}");
    }
  }
}