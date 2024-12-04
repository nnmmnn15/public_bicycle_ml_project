import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:public_bicycle/vm/myapi.dart';

class LoginHandler extends Myapi{
  final box = GetStorage();
  final RxString accessToken = ''.obs;
  final RxInt test = 0.obs;
  final serverurl = 
  // 'http://10.0.2.2';
  'http://127.0.0.1:8000';


  Future<void> login(String id, String password) async {
    print('id: $id');
    print('Password: $password');
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