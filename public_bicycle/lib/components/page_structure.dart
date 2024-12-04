import 'package:flutter/material.dart';
import 'main_header.dart';

class PageStructure extends StatelessWidget {
  final Widget? child;
  const PageStructure({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        MainHeader(),
        child != null
            ? SliverToBoxAdapter(child: child)
            : const SliverToBoxAdapter(
                child: SizedBox.shrink(),
              )
      ],
    );
  }
}
