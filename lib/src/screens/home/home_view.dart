import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/services/user_services.dart';
import 'package:flutter_final/src/widgets/app_bar_widget.dart';
import 'package:flutter_final/src/widgets/bottom_navi_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

import '../../widgets/vocab_list_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  State<HomeView> createState() => _HomeViewState();
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
  final List<Map<String, dynamic>> _folders = const [
    {
      "id": "1",
      "folderName": "Test",
      "description": "test description",
      "createdBy": {
        "username": "test",
        "avatarUrl": "",
      },
      "createdOn": "30/03/2023"
    },
    {
      "id": "1",
      "folderName": "Test",
      "description": "test description",
      "createdBy": {
        "username": "test",
        "avatarUrl": "",
      },
      "createdOn": "30/03/2023"
    },
    {
      "id": "1",
      "folderName": "Test",
      "description": "test description",
      "createdBy": {
        "username": "test",
        "avatarUrl": "",
      },
      "createdOn": "30/03/2023"
    },
    {
      "id": "1",
      "folderName": "Test",
      "description": "test description",
      "createdBy": {
        "username": "test",
        "avatarUrl": "",
      },
      "createdOn": "30/03/2023"
    },
    {
      "id": "1",
      "folderName": "Test",
      "description": "test description",
      "createdBy": {
        "username": "test",
        "avatarUrl": "",
      },
      "createdOn": "30/03/2023"
    },
    {
      "id": "1",
      "folderName": "Test",
      "description": "test description",
      "createdBy": {
        "username": "test",
        "avatarUrl": "",
      },
      "createdOn": "30/03/2023"
    },
  ];

  final List<Map<String, dynamic>> _topics = const [
    {
      "id": "1",
      "topicName": "Test",
      "description": "test description",
      "createdBy": {
        "username": "test",
        "avatarUrl": "",
      },
      "createdOn": "30/03/2023"
    },
    {
      "id": "1",
      "topicName": "Test",
      "description": "test description",
      "createdBy": {
        "username": "test",
        "avatarUrl": "",
      },
      "createdOn": "30/03/2023"
    },
    {
      "id": "1",
      "topicName": "Test",
      "description": "test description",
      "createdBy": {
        "username": "test",
        "avatarUrl": "",
      },
      "createdOn": "30/03/2023"
    },
    {
      "id": "1",
      "topicName": "Test",
      "description": "test description",
      "createdBy": {
        "username": "test",
        "avatarUrl": "",
      },
      "createdOn": "30/03/2023"
    },
    {
      "id": "1",
      "topicName": "Test",
      "description": "test description",
      "createdBy": {
        "username": "test",
        "avatarUrl": "",
      },
      "createdOn": "30/03/2023"
    },
    {
      "id": "1",
      "topicName": "Test",
      "description": "test description",
      "createdBy": {
        "username": "test",
        "avatarUrl": "",
      },
      "createdOn": "30/03/2023"
    },
  ];

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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome back, $userName! 🎉",
              style: GoogleFonts.roboto(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.all(20),
                ),
                splashFactory: NoSplash.splashFactory,
                backgroundColor: MaterialStateProperty.all(Colors.white),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/community-search');
              },
              child: const Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    "Search for topics, folders",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Folders 📁",
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFEEEEEE),
              ),
            ),
            const SizedBox(height: 12),
            CarouselSlider.builder(
              options: CarouselOptions(
                enableInfiniteScroll: false,
                height: 150,
                disableCenter: true,
                padEnds: false,
              ),
              itemCount: _folders.length,
              itemBuilder: (context, index, pageIndex) {
                return VocabListWidget(
                  onTap: () {
                    Navigator.pushNamed(context, '/folder', arguments: {"id": _folders[index]["id"]});
                  },
                  title: _folders[index]["folderName"],
                  description: _folders[index]["description"],
                  icon: const Icon(Icons.folder),
                  userName: _folders[index]["createdBy"]["username"],
                  isDeletable: false,
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              "Topics 📝",
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFEEEEEE),
              ),
            ),
            const SizedBox(height: 12),
            CarouselSlider.builder(
              options: CarouselOptions(
                enableInfiniteScroll: false,
                height: 150,
                disableCenter: true,
                padEnds: false,
              ),
              itemCount: _topics.length,
              itemBuilder: (context, index, pageIndex) {
                return VocabListWidget(
                  onTap: () {
                    Navigator.pushNamed(context, '/topic', arguments: {"id": _topics[index]["id"]});
                  },
                  title: _topics[index]["topicName"],
                  description: _topics[index]["description"],
                  icon: const Icon(Icons.book),
                  userName: _topics[index]["createdBy"]["username"],
                  isDeletable: false,
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNaviBar(index: 0),
    );
  }
}
