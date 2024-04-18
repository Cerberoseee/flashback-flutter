import 'package:flutter/material.dart';
import 'package:flutter_final/src/widgets/app_bar_widget.dart';
import 'package:flutter_final/src/widgets/bottom_navi_widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: const Text("Hello chat"),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNaviBar(index: 0),
    );
  }
}
