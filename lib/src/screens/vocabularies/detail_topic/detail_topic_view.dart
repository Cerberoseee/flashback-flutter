import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/enums.dart';
import 'package:flutter_final/src/helper/vocab_import_export.dart';
import 'package:flutter_final/src/services/topics_services.dart';
import 'package:flutter_final/src/widgets/add_edit_dialogue.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailTopicView extends StatefulWidget {
  final String id;
  static const routeName = "/topic";

  const DetailTopicView({super.key, this.id = ""});

  @override
  State<StatefulWidget> createState() => _DetailTopicState();
}

class _DetailTopicState extends State<DetailTopicView> {
  final _editFormKey = GlobalKey<FormState>();
  late List<Map<String, dynamic>>? _vocabList;
  late List<Map<String, dynamic>>? _staticVocabList;
  late dynamic _userTopicInfo;

  late TextEditingController _editTopicNameController, _editTopicDescController;

  late FlutterTts flutterTts;
  bool _visibleStatus = false, _isLoading = false, _isDialogueLoading = false;

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
    fetchDetailTopic();
    _setAwaitOptions();
  }

  void fetchDetailTopic() async {
    setState(() {
      _isLoading = true;
    });

    await getTopicDetail(widget.id).then((res) async {
      if (res != null) {
        List<Map<String, dynamic>> temp = (res['vocabularies'] as List).map((item) {
          Map<String, dynamic> res = item;
          return res;
        }).toList();
        if (mounted) {
          setState(() {
            _detailTopic = res;
            _visibleStatus = res["status"] == "public";
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();

          List<String> recentTopicId = prefs.getStringList("recentTopicList") ?? [];
          recentTopicId = recentTopicId.toSet().toList();
          recentTopicId.add(_detailTopic["id"]);
          await prefs.setStringList("recentTopicList", recentTopicId.take(5).toList());

          await getTopicUserInfo(_detailTopic["id"], FirebaseAuth.instance.currentUser?.uid ?? "", temp).then((infoRes) {
            List<Map<String, dynamic>> temp2 = (infoRes['vocabStatus'] as List).map((item) {
              Map<String, dynamic> res = item;
              return res;
            }).toList();

            List<Map<String, dynamic>> tempVocab = [
              for (final item1 in temp)
                {
                  ...item1,
                  ...temp2.firstWhere(((item2) => item1['vocabId'] == item2['vocabId']), orElse: () => {'status': 'notLearned', 'isStarred': false}),
                },
            ];
            if (mounted) {
              setState(() {
                _vocabList = tempVocab;
                _staticVocabList = tempVocab;
                _userTopicInfo = infoRes;
                _isLoading = false;
              });
            }
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went wrong, please try again!")));
        Navigator.pop(context);
      }
    });
  }

  Future<void> updateVocab() async {
    await patchTopicUserInfo(_detailTopic["id"], FirebaseAuth.instance.currentUser!.uid, {
      "vocabStatus": _staticVocabList?.map((e) {
        return {"vocabId": e["vocabId"], "status": e["status"], "isStarred": e["isStarred"]};
      }).toList(),
    });
  }

  @override
  void dispose() {
    super.dispose();
    updateVocab();
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

  Map<String, dynamic> _detailTopic = {};

  // final Map<String, dynamic> _detailTopic = {
  //   "id": "1",
  //   "topicName": "Test Topic",
  //   "description": "test description",
  //   "createdBy": {
  //     "username": "test",
  //     "avatarUrl": "",
  //   },
  //   "createdOn": "30/03/2023",
  //   "vocabularies": [
  //     {
  //       "en": "helo",
  //       "vi": "chao",
  //       "status": "unfavorite",
  //     },
  //     {
  //       "en": "wassup",
  //       "vi": "khoe ko",
  //       "status": "favorited",
  //     },
  //     {
  //       "en": "nice",
  //       "vi": "ngon",
  //       "status": "unfavorite",
  //     },
  //     {
  //       "en": "fine",
  //       "vi": "chac la on",
  //       "status": "mastered",
  //     },
  //     {
  //       "en": "vip",
  //       "vi": "pro",
  //       "status": "favorited",
  //     },
  //     {
  //       "en": "ayo",
  //       "vi": "e",
  //       "status": "mastered",
  //     },
  //   ]
  // };

  Future<void> showVisibleDialogue() async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateChild) {
          return AlertDialog(
            title: const Text(
              "Set Folder Visibility",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioListTile(
                  value: true,
                  groupValue: _visibleStatus,
                  title: const Row(children: [Icon(Icons.people_outline), SizedBox(width: 12), Text("Public")]),
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: (value) {
                    setStateChild(() {
                      _visibleStatus = value ?? true;
                    });
                    setState(() {
                      _visibleStatus = value ?? true;
                    });
                  },
                ),
                RadioListTile(
                  value: false,
                  groupValue: _visibleStatus,
                  title: const Row(children: [Icon(Icons.lock_rounded), SizedBox(width: 12), Text("Private")]),
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: (value) {
                    setStateChild(() {
                      _visibleStatus = value ?? true;
                    });
                    setState(() {
                      _visibleStatus = value ?? false;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text(
                  "Close",
                  style: TextStyle(
                    color: Color(0xFF76ABAE),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      ),
    ).then((res) async {
      await patchTopic(_detailTopic["id"], {"status": _visibleStatus ? "public" : "private"}).then((res) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res ? "Topic visibility updated!" : "Something went wrong, please try again!")));
      });
    });
  }

  Future<void> showEditDialogue() async {
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setChildState) {
          return AlertDialog(
            title: const Text(
              "Edit Topic",
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
                  Navigator.pop(ctx);
                },
              ),
              TextButton(
                onPressed: _isDialogueLoading
                    ? null
                    : () async {
                        if (_editFormKey.currentState!.validate()) {
                          setState(() {
                            _isDialogueLoading = true;
                          });
                          setChildState(() {
                            _isDialogueLoading = true;
                          });
                          await patchTopic(_detailTopic["id"], {
                            "topicName": _editTopicNameController.text,
                            "description": _editTopicDescController.text,
                            "topicNameQuery": _editTopicNameController.text.toLowerCase(),
                            "descriptionQuery": _editTopicDescController.text.toLowerCase(),
                          }).then((res) async {
                            setState(() {
                              _isDialogueLoading = false;
                            });
                            setChildState(() {
                              _isDialogueLoading = false;
                            });
                            if (res) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Topic edited successfully!")));
                              await updateVocab();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Topic edited failed, please try again!")));
                            }
                            Navigator.pop(ctx);
                            fetchDetailTopic();
                          });
                          // _editFormKey.currentState.save();
                        }
                      },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isDialogueLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator()) : Container(),
                    _isDialogueLoading ? const SizedBox(width: 12) : Container(),
                    const Text(
                      "Confirm",
                      style: TextStyle(
                        color: Color(0xFF76ABAE),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> showDelDialogue() async {
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setChildState) => AlertDialog(
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
              onPressed: _isDialogueLoading
                  ? null
                  : () async {
                      setState(() {
                        _isDialogueLoading = true;
                      });
                      setChildState(() {
                        _isDialogueLoading = true;
                      });
                      await deleteTopic(_detailTopic["id"]).then((res) {
                        setState(() {
                          _isDialogueLoading = false;
                        });
                        setChildState(() {
                          _isDialogueLoading = false;
                        });
                        if (res) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Topic deleted successfully!")));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Topic deleted failed, please try again!")));
                        }
                        Navigator.pop(ctx);
                        Navigator.pop(context, true);
                      });
                      // _editFormKey.currentState.save();
                    },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isDialogueLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator()) : Container(),
                  _isDialogueLoading ? const SizedBox(width: 12) : Container(),
                  const Text(
                    "Confirm",
                    style: TextStyle(
                      color: Color(0xFF76ABAE),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showBottomModalSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView(
                shrinkWrap: true,
                children: [
                  FirebaseAuth.instance.currentUser!.uid == _detailTopic["createdBy"]["id"]
                      ? ListTile(
                          leading: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          title: const Text("Edit"),
                          onTap: () {
                            Navigator.pop(ctx);
                            showEditDialogue();
                            _editTopicNameController.text = _detailTopic["topicName"] ?? "";
                            _editTopicDescController.text = _detailTopic["description"] ?? "";
                          },
                        )
                      : Container(),
                  FirebaseAuth.instance.currentUser!.uid == _detailTopic["createdBy"]["id"]
                      ? ListTile(
                          leading: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          title: const Text("Delete"),
                          onTap: () {
                            Navigator.pop(ctx);
                            showDelDialogue();
                          },
                        )
                      : Container(),
                  FirebaseAuth.instance.currentUser!.uid == _detailTopic["createdBy"]["id"]
                      ? ListTile(
                          leading: const Icon(
                            Icons.language,
                            color: Colors.white,
                          ),
                          title: const Text("Change Visibility"),
                          onTap: () {
                            Navigator.pop(ctx);
                            showVisibleDialogue();
                          },
                        )
                      : Container(),
                  ListTile(
                    leading: const Icon(
                      Icons.folder,
                      color: Colors.white,
                    ),
                    title: const Text("Add to Folder"),
                    onTap: () async {
                      Navigator.pop(ctx);
                      updateVocab().then((value) {
                        Navigator.of(context).pushNamed("/add-to-folder", arguments: {"topicId": _detailTopic["id"]});
                      });
                    },
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
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
      body: _isLoading
          ? const Column(
              mainAxisSize: MainAxisSize.max,
              children: [Expanded(child: Center(child: CircularProgressIndicator()))],
            )
          : SingleChildScrollView(
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
                              _detailTopic["createdBy"]["avatarUrl"] != "" ? NetworkImage(_detailTopic["createdBy"]["avatarUrl"]) : const AssetImage("images/default-avatar.png") as ImageProvider,
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
                          DateFormat('yyyy/MM/dd').format(DateTime.parse(_detailTopic["createdOn"])),
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        PopupMenuButton(
                          child: const Icon(
                            Icons.filter_list_rounded,
                            color: Colors.white,
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              onTap: () {
                                setState(() {
                                  _vocabList = _staticVocabList;
                                });
                              },
                              child: const Text("Show all"),
                            ),
                            PopupMenuItem(
                              onTap: () {
                                setState(() {
                                  _vocabList = _staticVocabList?.where((element) => element["isStarred"]).toList();
                                });
                              },
                              child: const Text("Show starred only"),
                            ),
                            PopupMenuItem(
                              onTap: () {
                                setState(() {
                                  _vocabList = _staticVocabList?.where((element) => element["status"] == VocabStatus.notLearned.name).toList();
                                });
                              },
                              child: const Text("Show not learned only"),
                            ),
                            PopupMenuItem(
                              onTap: () {
                                setState(() {
                                  _vocabList = _staticVocabList?.where((element) => element["status"] == VocabStatus.learned.name).toList();
                                });
                              },
                              child: const Text("Show learned only"),
                            ),
                            // PopupMenuItem(
                            //   onTap: () {
                            //     setState(() {
                            //       _vocabList = _staticVocabList?.where((element) => element["status"] == VocabStatus.mastered.name).toList();
                            //     });
                            //   },
                            //   child: const Text("Show mastered only"),
                            // ),
                          ],
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
                      itemCount: _vocabList?.length,
                      itemBuilder: (context, index, pageIndex) => StatefulBuilder(
                        builder: (ctx, setChildState) => Container(
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
                                    _vocabList?[index]["en"],
                                    style: const TextStyle(fontSize: 24.0),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _vocabList?[index]["vi"],
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
                                        _speak(_vocabList?[index]["en"]);
                                      },
                                      icon: const Icon(Icons.campaign),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _vocabList?[index]["isStarred"] = !_vocabList?[index]["isStarred"];
                                        });
                                        setChildState(() {
                                          _vocabList?[index]["isStarred"] = !_vocabList?[index]["isStarred"];
                                        });

                                        int vocabIndex = _staticVocabList?.indexWhere((element) => element["vocabId"] == _vocabList?[index]["vocabId"]) ?? -1;
                                        if (vocabIndex != -1) {
                                          _staticVocabList?[vocabIndex]["isStarred"] = !_staticVocabList?[vocabIndex]["isStarred"];
                                        }
                                      },
                                      icon: Icon(_vocabList?[index]["isStarred"] ? Icons.star : Icons.star_border),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "${_vocabList != null ? _vocabList?.length : 0} flashcard${(_vocabList!.length > 1) ? "s" : ""}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        FirebaseAuth.instance.currentUser!.uid == _detailTopic["createdBy"]["id"]
                            ? ListTile(
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
                                onTap: () async {
                                  updateVocab().then((value) async {
                                    var res = await Navigator.pushNamed(
                                      context,
                                      '/edit-topic',
                                      arguments: {"id": _detailTopic["id"], "vocabList": _staticVocabList},
                                    );
                                    if (res == true) {
                                      fetchDetailTopic();
                                    }
                                  });
                                },
                              )
                            : Container(),
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
                          onTap: () async {
                            if (_staticVocabList!.length >= 4) {
                              updateVocab().then((value) async {
                                await Navigator.pushNamed(
                                  context,
                                  "/flashcard-vocab",
                                  arguments: {
                                    "vocabList": _staticVocabList as List<Map<String, dynamic>>,
                                    "topicId": _detailTopic["id"],
                                    "userId": FirebaseAuth.instance.currentUser?.uid,
                                  },
                                );
                                fetchDetailTopic();
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please add at least 4 flashcards to use this functionality")));
                            }
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
                            updateVocab().then((value) async {
                              if (_staticVocabList!.length >= 4) {
                                await Navigator.pushNamed(
                                  context,
                                  "/vocab-test-setup",
                                  arguments: {
                                    "vocabList": _staticVocabList as List<Map<String, dynamic>>,
                                    "lastScore": _userTopicInfo["lastScore"] ?? 0,
                                    "userId": FirebaseAuth.instance.currentUser?.uid,
                                    "topicId": _detailTopic["id"],
                                  },
                                );
                                fetchDetailTopic();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please add at least 4 flashcards to use this functionality")));
                              }
                            });
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
                            updateVocab().then((value) async {
                              Navigator.pushNamed(context, "/topic-leaderboard", arguments: {
                                "topicId": _detailTopic["id"],
                              });
                            });
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
                            Icons.share,
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
                            if (await VocabImportExport.instance!.exportVocab(_detailTopic["vocabularies"], _detailTopic["topicName"])) {}
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
