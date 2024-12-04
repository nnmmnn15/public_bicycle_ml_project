import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../vm/login_handler.dart';

class Register extends StatelessWidget {
  Register({super.key});
  final loginHandler = Get.put(LoginHandler());
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController1 = TextEditingController();
  final TextEditingController passwordController2 = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController sexController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('회원가입'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 1.2,
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(7, 0, 0, 0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 1.8,
                          child: TextField(
                            controller: idController,
                            decoration: const InputDecoration(labelText: '아이디'),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: ElevatedButton(
                          onPressed: () => idSameCheck(idController.text.trim()),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white),
                          child: const Text('중복확인'),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                        controller: passwordController1,
                        decoration: const InputDecoration(labelText: '비밀번호'),
                        obscureText: true //비번 ****
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                        controller: passwordController2,
                        decoration: const InputDecoration(labelText: '비밀번호 확인'),
                        obscureText: true //비번 ****
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: '이름'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '나이'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: sexController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '성별'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () => joinClick(idController.text.trim()), //
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.yellow,
                          foregroundColor: Colors.black),
                      child: const Text('회원가입'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

//---function---

  idSameCheck(String checkId) async {
    if (checkId.isEmpty) {
      _showDialogCheck('아이디 확인', '아이디를 입력해주세요.');
    } else {
      
    }
  }

  // String 으로 체크
  _showDialogCheck(String title, String middleText) {
    //a-1 이미사용중인아이디
    Get.defaultDialog(
      title: title,
      middleText: middleText, //'사용 불가한 아이디입니다.',
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('확인'),
        )
      ]
    );
  }

  joinClick(String checkId) async {
    //b. 회원가입 버튼 클릭
    if (idController.text.trim().isEmpty ||
        passwordController1.text.trim().isEmpty ||
        passwordController2.text.trim().isEmpty ||
        nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      _showDialogCheck('경고', '빈칸을 채워주세요');
    } else {
      
      bool result = await loginHandler.signIn(idController.text.trim(), passwordController1.text.trim());
      if (result) {
        if (passwordController1.text.trim() ==
            passwordController2.text.trim()) {
            return 0;
        } else {
          _showDialogPasswordNo();
        }
      } else {
        _showDialogCheck('아이디 확인', '사용 불가한 아이디입니다.');
      }
    }
  }

  _showDialogPasswordNo() {
    //가입불가 확인창
    Get.defaultDialog(
        title: '경고.',
        middleText: '비밀번호를 확인해주세요.',
        barrierDismissible: false,
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('확인'),
          ),
        ]);
  }
}
