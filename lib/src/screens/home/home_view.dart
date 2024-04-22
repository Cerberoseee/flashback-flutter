import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/services/user_services.dart';
import 'package:flutter_final/src/widgets/app_bar_widget.dart';
import 'package:flutter_final/src/widgets/bottom_navi_widget.dart';
import 'package:logger/logger.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String userName = 'Guest';
  var logger = Logger();

  @override
  void initState() {
    super.initState();  
    fetchData();
    // _loadFolders();
  }

  // Map<String, dynamic> _detailFolder = {};
  // Future<void> _loadFolders() async {
  //   Map<String, dynamic>? folderData = await getFolderDetail('1osAYcFkfKA9LsLH70Dm');
  //   if (folderData != null) {
  //     _detailFolder = folderData;
  //     logger.e(_detailFolder);
  //     setState(() {});
  //   } else {
  //     logger.e('Error loading folder data: folderData is null');
  //   }
  // }

  void fetchData() async {
    final logger = Logger();
    try {
      String? emailUser = FirebaseAuth.instance.currentUser?.email;
      if (emailUser != null) {
        String name = await getNameFromEmail(emailUser);
        setState(() {
          userName = name;
        });
      }
    } catch (e) {
      logger.e('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Text("Hello $userName"),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNaviBar(index: 0),
    );
  }
}
