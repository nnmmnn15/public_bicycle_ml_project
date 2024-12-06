import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_bicycle/view/home.dart';
import 'package:public_bicycle/view/login.dart';
// import 'package:public_bicycle/view/login.dart';
import 'package:public_bicycle/view/mypage.dart';
import 'package:public_bicycle/view/sb/suspend_main.dart';
import 'package:public_bicycle/vm/header_handler.dart';
import 'package:public_bicycle/vm/home_handler.dart';
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
            height: headerHandler.appbarSize.value,
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
                          child: Icon(
                            headerHandler.showMenuList.value
                                ? Icons.close
                                : Icons.menu,
                            color: Colors.white,
                          ),
                        ),
                        title: const Row(
                          children: [
                            Text("따릉이", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        actions: [
                          InkWell(
                            onTap: () {
                              Get.to(
                                () => MyPage(),
                                transition: Transition.noTransition,
                              );
                            },
                            child: Text(
                              Get.find<HomeHandler>().userName.value,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () {
                              Get.find<HomeHandler>()
                                  .secureStorage
                                  .delete(key: 'refreshToken');
                              Get.find<HomeHandler>()
                                  .secureStorage
                                  .delete(key: 'accessToken');
                              Get.offAll(
                                () => Login(),
                                transition: Transition.noTransition,
                              );
                            },
                            child: const Text(
                              '로그아웃',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 0, 0),
                              ),
                            ),
                          ),
                        ],
                      )
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
                                    Get.offAll(() => const Home(),
                                        transition: Transition.noTransition);
                                  },
                                  child: const Text('따릉이홈',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                SizedBox(width: Get.width * 0.01),
                                InkWell(
                                  onTap: () {
                                    if (headerHandler
                                            .currentRentInfo.value!.resume >
                                        0) {
                                      Get.to(() => SuspendMain(),
                                          transition: Transition.noTransition);
                                    }
                                  },
                                  child: const Text('대여연장',
                                      style: TextStyle(color: Colors.white)),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Get.to(() => MyPage(),
                                        transition: Transition.noTransition);
                                  },
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '마이페이지',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    Get.find<HomeHandler>()
                                        .secureStorage
                                        .delete(key: 'refreshToken');
                                    Get.find<HomeHandler>()
                                        .secureStorage
                                        .delete(key: 'accessToken');
                                    Get.offAll(
                                      () => Login(),
                                      transition: Transition.noTransition,
                                    );
                                  },
                                  child: const Text(
                                    '로그아웃',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 255, 0, 0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                if (headerHandler.showMenuList.value)
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.home, color: Colors.white),
                          title: const Text("홈",
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            headerHandler.menuState();
                            headerHandler.menuSize();
                            Get.to(() => const Home(),
                                transition: Transition.noTransition);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.timer_outlined,
                              color: Colors.white),
                          title: const Text("예약연장",
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            if (headerHandler.currentRentInfo.value!.resume >
                                0) {
                              headerHandler.menuState();
                              headerHandler.menuSize();
                              Get.to(() => SuspendMain(),
                                  transition: Transition.noTransition);
                            }
                          },
                        ),
                        ListTile(
                          leading:
                              const Icon(Icons.person, color: Colors.white),
                          title: const Text("마이페이지",
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            headerHandler.menuState();
                            headerHandler.menuSize();
                            Get.to(() => MyPage(),
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
