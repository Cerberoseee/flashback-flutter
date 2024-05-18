import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/services/folders_services.dart';
import 'package:flutter_final/src/services/topics_services.dart';
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
  bool _isLoading = false;

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
  List<Map<String, dynamic>> _folders = [];

  List<Map<String, dynamic>> _topics = [];

  void fetchData() async {
    final logger = Logger();
    setState(() {
      _isLoading = true;
    });
    try {
      String? emailUser = FirebaseAuth.instance.currentUser?.email;
      if (emailUser != null) {
        dynamic user = await getUserByEmail(emailUser);
        if (mounted) {
          setState(() {
            userName = user['name'];
          });
        }
      }
      List<Map<String, dynamic>> fetchFolder = await getRecentFolder(5);
      List<Map<String, dynamic>> fetchTopic = await getRecentTopic(5);

      setState(() {
        _folders = fetchFolder;
        _topics = fetchTopic;
        _isLoading = false;
      });
    } catch (e) {
      logger.e('Error fetching data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome, $userName! 🎉",
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
                      "Recent Folders 📁",
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFEEEEEE),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _folders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 128,
                                  height: 128,
                                  child: Image.asset(kIsWeb ? "images/folder_empty.png" : "assets/images/folder_empty.png"),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "So empty...",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  "You can start by accessing Vocabularies, or visit others in Exploring",
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    CarouselSlider.builder(
                      options: CarouselOptions(
                        enableInfiniteScroll: false,
                        height: 160,
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
                          imgAvatar: _topics[index]["createdBy"]["avatarUrl"],
                          isDeletable: false,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Recent Topics 📝",
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFEEEEEE),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _topics.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 128,
                                  height: 128,
                                  child: Image.asset(kIsWeb ? "images/topic_empty.png" : "assets/images/topic_empty.png"),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "So empty...",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  "You can start by accessing Vocabularies, or visit others in Exploring",
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    CarouselSlider.builder(
                      options: CarouselOptions(
                        enableInfiniteScroll: false,
                        height: 160,
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
                          imgAvatar: _topics[index]["createdBy"]["avatarUrl"],
                          isDeletable: false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNaviBar(index: 0),
    );
  }
}
