import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/enums.dart';
import 'package:flutter_final/src/services/topics_services.dart';
import 'package:flutter_final/src/widgets/vocab_card.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe_cards/swipe_cards.dart';

class FlashcardVocabView extends StatefulWidget {
  final List<Map<String, dynamic>> vocabList;
  final String topicId, userId;
  static const routeName = "/flashcard-vocab";

  const FlashcardVocabView({super.key, required this.vocabList, this.topicId = "", this.userId = ""});

  @override
  State<StatefulWidget> createState() => _FlashcardVocabState();
}

class Vocabulary {
  final String en;
  final String vi;
  String status;
  bool isStarred;

  Vocabulary({this.en = "", this.vi = "", this.status = "notLearned", this.isStarred = false});
}

class _FlashcardVocabState extends State<FlashcardVocabView> {
  late TextEditingController _swipeDurationController, _flipDurationController;
  late List<SwipeItem> _swipeItems;
  MatchEngine? _matchEngine;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late Logger logger;
  late FlutterTts flutterTts;
  late bool _isAutoAudio;
  bool _isAuto = true, _isShuffleCards = false;
  int _currCard = 1;
  late double _flipDuration, _swipeDuration;
  late AnswerType _cardOrientation;
  late FlipCardController _cardController;
  late Timer? timer;
  late SharedPreferences prefs;
  late List<Map<String, dynamic>> _vocabList;

  bool _isLoading = true, _isSpeaking = false;

  void loadPref() async {
    prefs = await SharedPreferences.getInstance();
    _isAutoAudio = prefs.getBool('vocabIsAutoAudio') ?? true;
    _isAuto = false;
    _flipDuration = prefs.getDouble('vocabFlipDuration') ?? 1;
    _isShuffleCards = prefs.getBool('vocabIsShuffle') ?? false;
    _swipeDuration = prefs.getDouble('vocabSwipeDuration') ?? 1;
    _cardOrientation = (prefs.getBool("vocabOrient") ?? true) ? AnswerType.word : AnswerType.definition;
    _vocabList = widget.vocabList;

    if (_isShuffleCards) {
      _vocabList.shuffle();
    }

    _swipeItems = _vocabList.mapIndexed((index, item) {
      return SwipeItem(
        content: Vocabulary(
          en: item["en"],
          vi: item["vi"],
          status: item["status"],
          isStarred: item["isStarred"],
        ),
        likeAction: () {
          _vocabList[index]["status"] = "learned";
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Learned"),
            duration: Duration(milliseconds: 500),
          ));
        },
        nopeAction: () {
          _vocabList[index]["status"] = "notLearned";
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Still Learning"),
            duration: Duration(milliseconds: 500),
          ));
        },
      );
    }).toList();
    _matchEngine = MatchEngine(swipeItems: _swipeItems);

    if (_isAuto) {
      timer = Timer.periodic(
        Duration(milliseconds: ((_flipDuration + _swipeDuration + 0.2) * 1000).toInt()),
        (timer) async {
          if (!_isSpeaking) {
            if (_currCard == _vocabList.length) timer.cancel();

            await _cardController.toggleCard().then((value) {
              Timer(Duration(milliseconds: (_swipeDuration * 1000).toInt()), () {
                if (!_isAuto) {
                  timer.cancel();
                  return;
                }
                _matchEngine!.currentItem?.like();
              });
            });
          }
        },
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Timer(const Duration(milliseconds: 200), () async {
        if (_isAutoAudio && _cardOrientation == AnswerType.word) {
          await _speak(_vocabList[0]["en"]);
        }
      });
    }
  }

  @override
  void initState() {
    loadPref();
    flutterTts = FlutterTts();

    timer = null;
    _swipeDurationController = TextEditingController();
    _flipDurationController = TextEditingController();
    _cardController = FlipCardController();

    logger = Logger();

    super.initState();
  }

  @override
  void dispose() {
    updateVocab();
    flutterTts.stop();
    super.dispose();
  }

  void updateVocab() async {
    await patchTopicUserInfo(widget.topicId, widget.userId, {
      "vocabStatus": _vocabList.map((e) {
        return {"vocabId": e["vocabId"], "status": e["status"], "isStarred": false};
      }).toList(),
    });
  }

  void showSettingModal() {
    timer?.cancel();
    setState(() {
      _isAuto = false;
    });
    _flipDurationController.text = _flipDuration.toString();
    _swipeDurationController.text = _swipeDuration.toString();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, StateSetter setStateChild) {
            return Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 24),
                      SwitchListTile(
                        activeColor: const Color(0xFF76ABAE),
                        value: _isAutoAudio,
                        onChanged: (value) {
                          setStateChild(() {
                            _isAutoAudio = value;
                          });
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
                          setStateChild(() {
                            _isShuffleCards = value;
                          });
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
                              builder: (context, StateSetter setStateChildDialogue) {
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
                                            setStateChildDialogue(() {
                                              _cardOrientation = value!;
                                            });
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
                                            setStateChildDialogue(() {
                                              _cardOrientation = value!;
                                            });
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
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Close",
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
      },
    ).then((value) async {
      if (mounted) {
        setState(() {
          _flipDuration = double.parse(_flipDurationController.text);
          _swipeDuration = double.parse(_swipeDurationController.text);
        });
        await prefs.setBool('vocabIsAutoAudio', _isAutoAudio);
        await prefs.setDouble('vocabFlipDuration', _flipDuration);
        await prefs.setDouble('vocabSwipeDuration', _swipeDuration);
        await prefs.setBool("vocabOrient", _cardOrientation == AnswerType.word);
        await prefs.setBool("vocabIsShuffle", _isShuffleCards);
      }
    }).then((value) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => super.widget));
    });
  }

  Future<void> _speak(newVoiceText) async {
    await flutterTts.setLanguage('en-US');

    if (newVoiceText != null) {
      if (newVoiceText!.isNotEmpty && mounted) {
        setState(() {
          _isSpeaking = true;
        });
        await flutterTts.speak(newVoiceText!);
        await flutterTts.awaitSpeakCompletion(true);
        setState(() {
          _isSpeaking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text("${_currCard.toString()}/${_swipeItems.length}"),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () {
                    showSettingModal();
                  },
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),
            body: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 5 * 3.5,
                  child: SwipeCards(
                    matchEngine: _matchEngine!,
                    itemBuilder: (BuildContext context, int index) {
                      return VocabSwipeCard(
                        isAutoReadAfterFlipped: _isAutoAudio && _cardOrientation == AnswerType.definition,
                        controller: _cardController,
                        vi: _swipeItems[index].content.vi,
                        en: _swipeItems[index].content.en,
                        isFlipped: _cardOrientation == AnswerType.definition,
                        isFavorite: (_swipeItems[index].content.isStarred),
                        setFavorite: () {
                          setState(() {
                            _swipeItems[index].content.isStarred = !_swipeItems[index].content.isStarred;
                          });
                        },
                      );
                    },
                    onStackFinished: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Learning Finished"),
                        duration: Duration(milliseconds: 500),
                      ));
                    },
                    itemChanged: (SwipeItem item, int index) async {
                      flutterTts.stop();

                      if (_isAutoAudio) {
                        await _speak(_vocabList[_currCard]["en"]);
                      }
                      setState(() {
                        _currCard += 1;
                      });
                    },
                    upSwipeAllowed: false,
                    leftSwipeAllowed: !_isSpeaking,
                    rightSwipeAllowed: !_isSpeaking,
                    fillSpace: true,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _isSpeaking
                            ? null
                            : () {
                                _matchEngine!.currentItem?.nope();
                              },
                        style: ButtonStyle(
                          surfaceTintColor: MaterialStateProperty.all(const Color(0xFF76ABAE)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.arrow_back,
                              color: Color(0xFF76ABAE),
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Still Learning",
                              style: TextStyle(
                                color: Color(0xFF76ABAE),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _isSpeaking
                            ? null
                            : () {
                                _matchEngine!.currentItem?.like();
                              },
                        style: ButtonStyle(
                          surfaceTintColor: MaterialStateProperty.all(const Color(0xFF76ABAE)),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              "Learned",
                              style: TextStyle(
                                color: Color(0xFF76ABAE),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              color: Color(0xFF76ABAE),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: const Color(0xFF76ABAE),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
              ),
              onPressed: () {
                setState(() {
                  _isAuto = !_isAuto;
                });
                if (!_isAuto) {
                  timer?.cancel();
                } else {
                  timer = Timer.periodic(
                    Duration(milliseconds: ((_flipDuration + _swipeDuration + 0.2) * 1000).toInt()),
                    (timer) async {
                      if (!_isSpeaking) {
                        if (_currCard == _vocabList.length) timer.cancel();

                        await _cardController.toggleCard().then((value) {
                          Timer(Duration(milliseconds: (_swipeDuration * 1000).toInt()), () {
                            if (!_isAuto) {
                              timer.cancel();
                              return;
                            }
                            _matchEngine!.currentItem?.like();
                          });
                        });
                      }
                    },
                  );
                }
              },
              child: Icon(
                _isAuto ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
          );
  }
}
