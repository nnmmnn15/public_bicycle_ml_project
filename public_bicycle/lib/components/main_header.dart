import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                        backgroundColor: Colors.green,
                        leading: GestureDetector(
                          onTap: () {
                            headerHandler.menuState();
                            headerHandler.menuSize();
                          },
                          child: Icon(
                            Icons.menu,
                            color: Colors.white,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text("따릉이", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      )

                    // 메뉴바 없는 상태
                    : AppBar(
                        backgroundColor: Colors.green,
                        title: Row(
                          children: [
                            Text("따릉이", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                if (headerHandler.showMenuList.value) // 확장 상태일 때만 목록 표시
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.home, color: Colors.white),
                          title: const Text("Home",
                              style: TextStyle(color: Colors.white)),
                          onTap: () {},
                        ),
                        ListTile(
                          leading:
                              const Icon(Icons.settings, color: Colors.white),
                          title: const Text("Settings",
                              style: TextStyle(color: Colors.white)),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: const Icon(Icons.info, color: Colors.white),
                          title: const Text("About",
                              style: TextStyle(color: Colors.white)),
                          onTap: () {},
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
