import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_bicycle/view/home.dart';
// import 'package:public_bicycle/view/login.dart';
import 'package:public_bicycle/view/mypage.dart';
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
                    : AppBar(
                        automaticallyImplyLeading: false,
                        backgroundColor: Colors.green,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: const Text('따릉이홈',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                SizedBox(width: Get.width * 0.01),
                                InkWell(
                                  onTap: () {
                                    Get.to(() => SuspendMain(),
                                        transition: Transition.noTransition);
                                  },
                                  child: const Text('예약연장',
                                      style: TextStyle(color: Colors.white)),
                                )
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                Get.to(() => MyPage(),
                                    transition: Transition.noTransition);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
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
                            Get.to(() => SuspendMain(),
                                transition: Transition.noTransition);
                          },
                        ),
                        ListTile(
                          leading:
                              const Icon(Icons.person, color: Colors.white),
                          title: const Text("마이페이지",
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
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
