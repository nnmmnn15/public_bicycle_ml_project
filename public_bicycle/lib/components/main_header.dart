import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_bicycle/view/home.dart';
import 'package:public_bicycle/view/login.dart';
import 'package:public_bicycle/view/sb/suspend_main.dart';
import 'package:public_bicycle/vm/header_handler.dart';
import 'package:responsive_framework/responsive_framework.dart' as responsive;

class MainHeader extends StatelessWidget {
  MainHeader({super.key});

  final headerHandler = Get.put(HeaderHandler());
  @override
  Widget build(BuildContext context) {
    headerHandler.showMenuList.value = responsive.ResponsiveValue(
      context,
      defaultValue: headerHandler.showMenuList.value,
      conditionalValues: [
        const responsive.Condition.largerThan(
            value: false, name: responsive.TABLET),
      ],
    ).value;
    headerHandler.appbarSize.value = responsive.ResponsiveValue(
      context,
      defaultValue: headerHandler.appbarSize.value,
      conditionalValues: [
        const responsive.Condition.largerThan(
            value: kToolbarHeight, name: responsive.TABLET),
      ],
    ).value;
    return Obx(() => SliverAppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.green,
          floating: true,
          snap: true,
          title: SizedBox(
            height: headerHandler.appbarSize.value, // 확장된 높이와 기본 높이
            child: Column(
              children: [
                responsive.ResponsiveValue(
                  context,
                  defaultValue: true,
                  conditionalValues: [
                    const responsive.Condition.largerThan(
                        value: false, name: responsive.TABLET)
                  ],
                ).value
                    ? AppBar(
                        automaticallyImplyLeading: false,
                        backgroundColor: Colors.green,
                        leading: GestureDetector(
                          onTap: () {
                            headerHandler.menuState();
                            headerHandler.menuSize();
                          },
                          child: const Icon(
                            Icons.menu,
                            color: Colors.white,
                          ),
                        ),
                        title: const Row(
                          children: [
                            Text("따릉이", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      )

                    // 메뉴바 없는 상태
                    : AppBar(
                        automaticallyImplyLeading: false,
                        backgroundColor: Colors.green,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    //
                                  },
                                  child: const Text('따릉이홈',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                SizedBox(
                                  width: Get.width * 0.01,
                                ),
                                InkWell(
                                  onTap: () {
                                    Get.to(
                                      () => SuspendMain(),
                                      transition: Transition.noTransition,
                                    );
                                  },
                                  child: const Text('예약연장',
                                      style: TextStyle(color: Colors.white)),
                                )
                              ],
                            ),
                            // 로그인 상태에따라 변화
                            InkWell(
                              onTap: () {
                                Get.to(() => Login(),
                                    transition: Transition.noTransition);
                              },
                              child: const Text('로그인',
                                  style: TextStyle(color: Colors.white)),
                            )
                          ],
                        ),
                      ),
                if (headerHandler.showMenuList.value) // 확장 상태일 때만 목록 표시
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.home, color: Colors.white),
                          title: const Text("홈",
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            Get.to(
                              () => const Home(),
                              transition: Transition.noTransition,
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.timer_outlined,
                              color: Colors.white),
                          title: const Text("예약연장",
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            Get.to(
                              () => SuspendMain(),
                              transition: Transition.noTransition,
                            );
                          },
                        ),
                        // 로그인 상태에 따라 변화 로그아웃으로 변화
                        ListTile(
                          leading: const Icon(Icons.login, color: Colors.white),
                          title: const Text("로그인",
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            Get.to(() => Login(),
                                transition: Transition.noTransition);
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          toolbarHeight: headerHandler.appbarSize.value,
        ));
  }
}
