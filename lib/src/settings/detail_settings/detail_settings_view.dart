import 'package:flutter/material.dart';
import 'package:flutter_final/src/enums.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailSettingView extends StatefulWidget {
  const DetailSettingView({super.key});

  static const routeName = "/detail-settings";

  @override
  State<DetailSettingView> createState() => _DetailSettingState();
}

class _DetailSettingState extends State<DetailSettingView> {
  TestType _testType = TestType.trueFalse;
  AnswerType _answerType = AnswerType.word, _cardOrientation = AnswerType.word;
  final TextEditingController _flipDurationController = TextEditingController(), _swipeDurationController = TextEditingController();
  late SharedPreferences prefs;
  bool _isAutoAudio = false, _isShuffleCards = false, _isAutoSwipe = false, _instantAnswer = false;

  @override
  void initState() {
    super.initState();
    fetchPref();
  }

  void fetchPref() async {
    prefs = await SharedPreferences.getInstance();

    setState(() {
      if (prefs.getString("settingTestType") != null) {
        _testType = TestType.values.firstWhere((e) => e.toString() == prefs.getString("settingTestType"));
      }
      if (prefs.getString("settingAnswerType") != null) {
        _answerType = AnswerType.values.firstWhere((e) => e.toString() == prefs.getString("settingAnswerType"));
      }
      _instantAnswer = prefs.getBool("settingInstantAnswer") ?? false;

      if (prefs.getString("settingOrientation") != null) {
        _cardOrientation = AnswerType.values.firstWhere((e) => e.toString() == prefs.getString("settingOrientation"));
      }
      _flipDurationController.text = prefs.getDouble("settingFlipDuration")?.toString() ?? "0";
      _swipeDurationController.text = prefs.getDouble("settingSwipeDuration")?.toString() ?? "0";
      _isAutoAudio = prefs.getBool("settingAutoplayAudio") ?? false;
      _isShuffleCards = prefs.getBool("settingShuffle") ?? false;
      _isAutoSwipe = prefs.getBool("settingAutoSwipe") ?? false;
    });
  }

  void putPref() async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString("settingTestType", _testType.toString());
    await prefs.setString("settingAnswerType", _answerType.toString());
    await prefs.setBool("settingInstantAnswer", _instantAnswer);

    await prefs.setString("settingOrientation", _cardOrientation.toString());
    await prefs.setBool("settingAutoplayAudio", _isAutoAudio);
    await prefs.setBool("settingAutoSwipe", _isAutoSwipe);
    await prefs.setBool("settingShuffle", _isShuffleCards);
    await prefs.setDouble("settingFlipDuration", double.parse(_flipDurationController.text != "" ? _flipDurationController.text : "0"));
    await prefs.setDouble("settingSwipeDuration", double.parse(_swipeDurationController.text != "" ? _flipDurationController.text : "0"));
  }

  @override
  void dispose() {
    _flipDurationController.dispose();
    _swipeDurationController.dispose();
    putPref();
    super.dispose();
  }

  Future<void> showAnswerTypeBottomSheet() async {
    await showModalBottomSheet(
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
                    title: const Text("Word"),
                    onTap: () {
                      setState(() {
                        _answerType = AnswerType.word;
                      });
                      Navigator.pop(context);
                    },
                    trailing: (_answerType == AnswerType.word) ? const Icon(Icons.done) : const SizedBox(),
                  ),
                  ListTile(
                    title: const Text("Definition"),
                    onTap: () {
                      setState(() {
                        _answerType = AnswerType.definition;
                      });
                      Navigator.pop(context);
                    },
                    trailing: (_answerType == AnswerType.definition) ? const Icon(Icons.done) : const SizedBox(),
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
        title: Text(
          "FlashBack",
          style: GoogleFonts.robotoCondensed(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFEEEEEE),
          ),
        ),
        backgroundColor: const Color(0xFF222831),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    "Test Settings",
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Divider(),
                  SwitchListTile(
                    activeColor: const Color(0xFF76ABAE),
                    value: _instantAnswer,
                    onChanged: (value) {
                      setState(() {
                        _instantAnswer = value;
                      });
                    },
                    title: const Text("Instant Correct Answer"),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    onTap: () async {
                      await showAnswerTypeBottomSheet();
                    },
                    title: Text("Answer with: ${(_answerType == AnswerType.word) ? "Word" : "Definition"}"),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_sharp,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  RadioListTile(
                    activeColor: const Color(0xFF76ABAE),
                    value: TestType.trueFalse,
                    groupValue: _testType,
                    onChanged: (TestType? value) {
                      setState(() {
                        _testType = value!;
                      });
                    },
                    title: const Text("True/False"),
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                  RadioListTile(
                    activeColor: const Color(0xFF76ABAE),
                    value: TestType.written,
                    groupValue: _testType,
                    onChanged: (TestType? value) {
                      setState(() {
                        _testType = value!;
                      });
                    },
                    title: const Text("Written"),
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                  RadioListTile(
                    activeColor: const Color(0xFF76ABAE),
                    value: TestType.multiple,
                    groupValue: _testType,
                    onChanged: (TestType? value) {
                      setState(() {
                        _testType = value!;
                      });
                    },
                    title: const Text("Multiple Choices"),
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Flashcard Settings",
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Divider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          SwitchListTile(
                            activeColor: const Color(0xFF76ABAE),
                            value: _isAutoSwipe,
                            onChanged: (value) {
                              setState(() {
                                _isAutoSwipe = value;
                              });
                            },
                            title: const Text("Auto swipe Flashcard"),
                          ),
                          SwitchListTile(
                            activeColor: const Color(0xFF76ABAE),
                            value: _isAutoAudio,
                            onChanged: (value) {
                              setState(() {
                                _isAutoAudio = value;
                              });
                            },
                            title: const Text("Auto play audio"),
                          ),
                          SwitchListTile(
                            activeColor: const Color(0xFF76ABAE),
                            value: _isShuffleCards,
                            onChanged: (value) {
                              setState(() {
                                _isShuffleCards = value;
                              });
                            },
                            title: const Text("Shuffle Flashcards"),
                          ),
                          ListTile(
                            title: Text("Front card orientation: ${(_cardOrientation == AnswerType.word) ? "Word" : "Definition"}"),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_sharp,
                              color: Colors.white,
                              size: 16,
                            ),
                            onTap: () async {
                              await showDialog(
                                context: context,
                                builder: (context) => StatefulBuilder(
                                  builder: (context, StateSetter setStateChild) {
                                    return AlertDialog(
                                      title: const Text(
                                        "Select Orientation",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      content: SizedBox(
                                        width: 400,
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: [
                                            RadioListTile(
                                              title: const Text("Definition"),
                                              activeColor: const Color(0xFF76ABAE),
                                              controlAffinity: ListTileControlAffinity.trailing,
                                              value: AnswerType.definition,
                                              groupValue: _cardOrientation,
                                              onChanged: (AnswerType? value) {
                                                setStateChild(() {
                                                  _cardOrientation = value!;
                                                });
                                                setState(() {
                                                  _cardOrientation = value!;
                                                });
                                              },
                                            ),
                                            RadioListTile(
                                              title: const Text("Word"),
                                              activeColor: const Color(0xFF76ABAE),
                                              controlAffinity: ListTileControlAffinity.trailing,
                                              value: AnswerType.word,
                                              groupValue: _cardOrientation,
                                              onChanged: (AnswerType? value) {
                                                setStateChild(() {
                                                  _cardOrientation = value!;
                                                });
                                                setState(() {
                                                  _cardOrientation = value!;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text(
                                            "Confirm",
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
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          ListTile(
                            title: const Text("Auto flip Delay (in seconds)"),
                            trailing: SizedBox(
                              width: 64,
                              child: TextField(
                                controller: _flipDurationController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ),
                          ListTile(
                            title: const Text("Auto swipe Delay (in seconds)"),
                            trailing: SizedBox(
                              width: 64,
                              child: TextField(
                                controller: _swipeDurationController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
