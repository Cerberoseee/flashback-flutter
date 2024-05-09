import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/services/folders_services.dart';
import 'package:flutter_final/src/services/topics_services.dart';
import 'package:flutter_final/src/services/vocab_services.dart';
import 'package:flutter_final/src/widgets/app_bar_widget.dart';
import 'package:flutter_final/src/widgets/bottom_navi_widget.dart';
import 'package:flutter_final/src/widgets/vocab_list_widget.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

class CommunityView extends StatefulWidget {
  const CommunityView({super.key});
  static const routeName = "/community";
  @override
  State<StatefulWidget> createState() => _CommunityState();
}

class _CommunityState extends State<CommunityView> {
  late String _randomVocab, _randomVocabMeaning;
  late FlutterTts flutterTts;

  bool _isLoading = true;
  List<Map<String, dynamic>> _folders = [];
  List<Map<String, dynamic>> _topics = [];

  // final List<Map<String, dynamic>> _folders = const [
  //   {
  //     "id": "1",
  //     "folderName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  //   {
  //     "id": "1",
  //     "folderName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  //   {
  //     "id": "1",
  //     "folderName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  //   {
  //     "id": "1",
  //     "folderName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  //   {
  //     "id": "1",
  //     "folderName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  //   {
  //     "id": "1",
  //     "folderName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  // ];

  // final List<Map<String, dynamic>> _topics = const [
  //   {
  //     "id": "1",
  //     "topicName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  //   {
  //     "id": "1",
  //     "topicName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  //   {
  //     "id": "1",
  //     "topicName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  //   {
  //     "id": "1",
  //     "topicName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  //   {
  //     "id": "1",
  //     "topicName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  //   {
  //     "id": "1",
  //     "topicName": "Test",
  //     "description": "test description",
  //     "createdBy": {
  //       "username": "test",
  //       "avatarUrl": "",
  //     },
  //     "createdOn": "30/03/2023"
  //   },
  // ];

  void fetchData() async {
    List<dynamic> res = await getRandomVocab();
    List<Map<String, dynamic>> fetchFolder = await getAllFolder(5);
    List<Map<String, dynamic>> fetchTopic = await getAllTopic(5);

    if (mounted) {
      setState(() {
        _folders = fetchFolder;
        _topics = fetchTopic;
        _randomVocab = res[0]["word"];
        _randomVocabMeaning = res[0]["definition"];
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _setAwaitOptions();
    fetchData();
  }

  Future<void> _setAwaitOptions() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _speak(newVoiceText) async {
    await flutterTts.awaitSpeakCompletion(true);

    if (newVoiceText != null) {
      if (newVoiceText!.isNotEmpty) {
        await flutterTts.speak(newVoiceText!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        actionList: [
          IconButton(
            onPressed: _isLoading
                ? null
                : () {
                    Navigator.pushNamed(context, "/community-search");
                  },
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Exploring 🔍",
                      style: GoogleFonts.roboto(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFEEEEEE),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Random vocabulary ❓",
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFEEEEEE),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Stack(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          color: const Color(0xFF222831),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _randomVocab,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(_randomVocabMeaning),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: IconButton(
                            onPressed: () {
                              _speak(_randomVocab);
                            },
                            icon: const Icon(
                              Icons.campaign,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Recently added public folders",
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
                      "Recently added public topics",
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
            ),
      bottomNavigationBar: BottomNaviBar(
        index: 2,
      ),
    );
  }
}
