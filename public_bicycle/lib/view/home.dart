import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_bicycle/vm/login_handler.dart';

class Home extends StatelessWidget {
  const Home({super.key});
@override
  Widget build(BuildContext context) {
    final loginHandler = Get.put(LoginHandler());
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  loginHandler.jwtTokenTest();
                }, 
                child: const Text('이름 가져오기')
              ),
              Obx(() =>  Text(loginHandler.test.value == 0 ? '이름을 가져오세요' : loginHandler.test.value.toString()),)
            ],
          ),
          // FutureBuilder(
          //   future: loginHandler.getAccessToken(),
          //   builder: (context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return Center(child: CircularProgressIndicator()); // 로딩 중
          //     } else if (snapshot.hasError) {
          //       return Center(child: Text('Error: ${snapshot.error}')); // 에러 처리
          //     }else {
          //       return Center(child: Text('Access Token: ${snapshot.data}')); // AccessToken 표시
          //     }
          //   },
          // )
        ],
      ),
    );
  }
}