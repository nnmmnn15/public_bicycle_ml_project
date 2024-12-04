import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_bicycle/view/home.dart';
import 'package:public_bicycle/view/register.dart';
import 'package:public_bicycle/vm/login_handler.dart';

class Login extends StatelessWidget {
  Login({super.key});
  final loginHandler = Get.put(LoginHandler());
  @override
  Widget build(BuildContext context) {
    TextEditingController idController= TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('로그인'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
               
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    controller: idController,
                    decoration: const InputDecoration(labelText: '아이디를 입력하세요'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                  child: TextField(
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: '비밀번호를 입력하세요',
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 30, 0),
                      child: ElevatedButton(
                        onPressed: () async {
                          // await loginHandler.login('wylee99', 'wy12wy10');
                          await loginHandler.login(idController.text.trim(), 
                          passwordController.text.trim());
                          String? token = await loginHandler.secureStorage.read(key: 'accessToken');
                          // Get.to();
                          print(token);
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.yellow,
                            foregroundColor: Colors.black),
                        child: const Text('로 그 인'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 30, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('아이디가 없다면?    '),
                          ElevatedButton(
                            onPressed: (){
                              Get.to(()=> Register());
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('회원가입'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showDialogPasswordOk() async {
    //가입ok 환영창
    Get.defaultDialog(
      title: '로그인',
      // middleText: '$name 님 환영합니다.',
      backgroundColor: Colors.white,
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            Get.off(
              () => const Home(),
            );
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.brown[100],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('확인'),
        ),
      ],
    );
  }
  
}
