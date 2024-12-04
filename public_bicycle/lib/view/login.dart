import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/view/home.dart';
import '/view/register.dart';
import '/vm/login_handler.dart';

class Login extends StatelessWidget {
  Login({super.key});
  final loginHandler = Get.put(LoginHandler());
  @override
  Widget build(BuildContext context) {
    final TextEditingController idController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
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
                          final id = idController.text.trim();
                          final password = passwordController.text.trim();
                          if (id.isEmpty || password.isEmpty) {
                            Get.snackbar('Error', 'ID 또는 Password를 입력해주세요.');
                            return;
                          }
                          await loginHandler.login(id, password);
                          await Get.offAll(()=>const Home());
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
                            onPressed: () {
                              Get.to(() => Register());
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('확인'),
        ),
      ],
    );
  }
}
