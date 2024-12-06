import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_bicycle/view/home.dart';
import 'package:public_bicycle/view/register.dart';
import 'package:public_bicycle/vm/login_handler.dart';
import 'package:responsive_framework/responsive_framework.dart' as responsive;

class Login extends StatelessWidget {
  Login({super.key});
  final loginHandler = Get.put(LoginHandler());
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    loginHandler.hasTokken();
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
                    onSubmitted: (value) => login(),
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
                            await login();
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.yellow,
                              foregroundColor: Colors.black),
                          child: const Text('로 그 인'),
                        )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 30, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('아이디가 없다면?    '),
                          responsive.ResponsiveValue(
                            context,
                            defaultValue: true,
                            conditionalValues: [
                              const responsive.Condition.largerThan(
                                  value: false, name: responsive.TABLET),
                            ],
                          ).value
                              ? ElevatedButton(
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
                                )
                              : InkWell(
                                  onTap: () => Get.to(() => Register()),
                                  child: Text(
                                    '회원가입',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
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
              () => Home(),
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

  clearField() async {
    idController.text = '';
    passwordController.text = '';
  }

  login() async {
    final id = idController.text.trim();
    final password = passwordController.text.trim();
    if (id.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'ID 또는 Password를 입력해주세요.');
      return;
    }
    await loginHandler.login(id, password);
    await clearField();
    await Get.offAll(() => const Home());
  }
}
