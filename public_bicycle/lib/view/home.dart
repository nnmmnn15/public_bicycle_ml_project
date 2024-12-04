import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../vm/login_handler.dart';

class Home extends StatelessWidget {
  const Home({super.key});
@override
  Widget build(BuildContext context) {
    final loginHandler = Get.put(LoginHandler());
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          loginHandler.secureStorage.read(key: 'accessToken') == '' ? Text('로그인 실패') : Text(
            '로그인 성공${loginHandler.secureStorage.read(key: 'accessToken')}'
          ),
          FutureBuilder(
            future: loginHandler.getAccessToken(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator()); // 로딩 중
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}')); // 에러 처리
              }else {
                return Center(child: Text('Access Token: ${snapshot.data}')); // AccessToken 표시
              }
            },
          )
        ],
      ),
    );
  }
}