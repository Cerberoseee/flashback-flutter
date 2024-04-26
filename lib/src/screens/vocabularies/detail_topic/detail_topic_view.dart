import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/helper/vocab_import_export.dart';
import 'package:flutter_final/src/widgets/add_edit_dialogue.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailTopicView extends StatefulWidget {
  final String id;
  static const routeName = "/topic";

  const DetailTopicView({super.key, this.id = ""});

  @override
  State<StatefulWidget> createState() => _DetailTopicState();
}

class _DetailTopicState extends State<DetailTopicView> {
  final _editFormKey = GlobalKey<FormState>();
  late TextEditingController _editTopicNameController, _editTopicDescController;

  late FlutterTts flutterTts;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  @override
  void initState() {
    super.initState();
    _editTopicNameController = TextEditingController();
    _editTopicDescController = TextEditingController();
    flutterTts = FlutterTts();
    _setAwaitOptions();
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  Future<void> _setAwaitOptions() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _speak(newVoiceText) async {
    if (newVoiceText != null) {
      if (newVoiceText!.isNotEmpty) {
        await flutterTts.speak(newVoiceText!);
      }
    }
  }

  final Map<String, dynamic> _detailTopic = {
    "id": "1",
    "topicName": "Test Topic",
    "description": "test description",
    "createdBy": {
      "username": "test",
      "avatarUrl": "",
    },
    "createdOn": "30/03/2023",
    "vocabularies": [
      {
        "en": "helo",
        "vi": "chao",
        "status": "unfavorite",
      },
      {
        "en": "wassup",
        "vi": "chao",
        "status": "unfavorite",
      },
      {
        "en": "nice",
        "vi": "ngon",
        "status": "unfavorite",
      },
    ]
  };

  Future<void> showEditDialogue() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Edit Folder",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: SizedBox(
          width: 400,
          child: AddEditWidget(
            descriptionController: _editTopicDescController,
            nameController: _editTopicNameController,
            formKey: _editFormKey,
          ),
        ),
        actions: [
          TextButton(
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Color(0xFF76ABAE),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text(
              "Confirm",
              style: TextStyle(
                color: Color(0xFF76ABAE),
              ),
            ),
            onPressed: () {
              if (_editFormKey.currentState!.validate()) {
                //edit api service goes here
                Navigator.pop(context);
                // _editFormKey.currentState.save();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> showDelDialogue() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Delete Topic",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: const SizedBox(
          width: 400,
          child: Text("Are you sure you want to delete this topic?"),
        ),
        actions: [
          TextButton(
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Color(0xFF76ABAE),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text(
              "Confirm",
              style: TextStyle(
                color: Color(0xFF76ABAE),
              ),
            ),
            onPressed: () {
              //edit api service goes here
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void showBottomModalSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    title: const Text("Edit"),
                    onTap: () {
                      Navigator.pop(context);
                      showEditDialogue();
                      _editTopicNameController.text = _detailTopic["topicName"] ?? "";
                      _editTopicDescController.text = _detailTopic["description"] ?? "";
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    title: const Text("Delete"),
                    onTap: () {
                      Navigator.pop(context);
                      showDelDialogue();
                    },
                  )
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: const Color(0xFF222831),
        backgroundColor: const Color(0xFF222831),
        actions: [
          IconButton(
            onPressed: () {
              showBottomModalSheet();
            },
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _detailTopic["topicName"],
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _detailTopic["description"],
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 16,
                    backgroundImage:
                        _detailTopic["createdBy"]["avatarUrl"] != "" ? NetworkImage(_detailTopic["createdBy"]["avatarUrl"]) : const AssetImage("/images/default-avatar.png") as ImageProvider,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Text(
                      _detailTopic["createdBy"]["username"],
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _detailTopic["createdOn"],
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CarouselSlider.builder(
                options: CarouselOptions(
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  height: MediaQuery.of(context).size.height / 2.5,
                ),
                itemCount: _detailTopic["vocabularies"].length,
                itemBuilder: (context, index, pageIndex) => Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF222831),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _detailTopic["vocabularies"][index]["en"],
                            style: const TextStyle(fontSize: 24.0),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _detailTopic["vocabularies"][index]["vi"],
                            style: const TextStyle(fontSize: 24.0),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                _speak(_detailTopic["vocabularies"][index]["en"]);
                              },
                              icon: const Icon(Icons.campaign),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  if (_detailTopic["vocabularies"][index]["status"] == "favorited") {
                                    _detailTopic["vocabularies"][index]["status"] = "unfavorite";
                                  } else {
                                    _detailTopic["vocabularies"][index]["status"] = "favorited";
                                  }
                                });
                              },
                              icon: Icon(_detailTopic["vocabularies"][index]["status"] == "favorited" ? Icons.star : Icons.star_border),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "${_detailTopic["vocabularies"] != null ? _detailTopic["vocabularies"].length : 0} flashcard${(_detailTopic["vocabularies"].length > 1 || _detailTopic["vocabularies"].length != null) ? "s" : ""}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    tileColor: const Color(0xFF222831),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    leading: const Icon(
                      Icons.abc,
                      color: Color(0xFF76ABAE),
                    ),
                    title: const Text(
                      "Edit Collections",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF76ABAE),
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/edit-topic',
                        arguments: {"id": _detailTopic["id"]},
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    tileColor: const Color(0xFF222831),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    leading: const Icon(
                      Icons.menu_book,
                      color: Color(0xFF76ABAE),
                    ),
                    title: const Text(
                      "Learn by Flashcard",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF76ABAE),
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "/flashcard-vocab",
                        arguments: {"vocabList": _detailTopic["vocabularies"]},
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    tileColor: const Color(0xFF222831),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    leading: const Icon(
                      Icons.quiz,
                      color: Color(0xFF76ABAE),
                    ),
                    title: const Text(
                      "Test",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF76ABAE),
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "/vocab-test-setup",
                        arguments: {
                          "vocabList": _detailTopic["vocabularies"],
                          "lastScore": 0,
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    tileColor: const Color(0xFF222831),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    leading: const Icon(
                      Icons.leaderboard,
                      color: Color(0xFF76ABAE),
                    ),
                    title: const Text(
                      "Leaderboard",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF76ABAE),
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "/topic-leaderboard",
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    tileColor: const Color(0xFF222831),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    leading: const Icon(
                      Icons.abc,
                      color: Color(0xFF76ABAE),
                    ),
                    title: const Text(
                      "Export Vocabularies",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF76ABAE),
                      ),
                    ),
                    onTap: () async {
                      if (await VocabImportExport.exportVocab(_detailTopic["vocabularies"], _detailTopic["topicName"])) {
                        print("ok");
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
