import 'package:flutter/material.dart';

class BottomNaviBar extends StatelessWidget {
  final int index;

  BottomNaviBar({
    super.key,
    required this.index,
  });

  final List<String> routeList = ['/home', '/vocab', '/community', '/settings'];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      unselectedItemColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      backgroundColor: const Color(0xFF222831),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.menu_book,
          ),
          label: 'Vocabularies',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.language,
          ),
          label: 'Exploring',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.account_circle_outlined,
          ),
          label: 'Profile',
        ),
      ],
      currentIndex: index,
      selectedItemColor: const Color(0xFF76ABAE),
      selectedIconTheme: const IconThemeData(
        color: Color(0xFF76ABAE),
      ),
      onTap: (index) {
        Navigator.popAndPushNamed(context, routeList[index]);
      },
    );
  }
}
