import 'dart:async';

import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/widgets/vocab_card.dart';
import 'package:logger/logger.dart';
import 'package:swipe_cards/swipe_cards.dart';

class FlashcardVocabView extends StatefulWidget {
  final List<Map<String, dynamic>> vocabList;
  static const routeName = "/flashcard-vocab";

  const FlashcardVocabView({super.key, required this.vocabList});

  @override
  State<StatefulWidget> createState() => _FlashcardVocabState();
}

class Vocabulary {
  final String en;
  final String vi;
  String status;

  Vocabulary({this.en = "", this.vi = "", this.status = ""});
}

class _FlashcardVocabState extends State<FlashcardVocabView> {
  late List<SwipeItem> _swipeItems;
  MatchEngine? _matchEngine;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late Logger logger;

  late bool _isAuto;
  int _currCard = 1;
  late double _flipDuration, _swipeDuration;

  late FlipCardController _cardController;
  late Timer timer;

  @override
  void initState() {
    _cardController = FlipCardController();
    _isAuto = true;
    _flipDuration = 1;
    _swipeDuration = 1;
    logger = Logger();
    _swipeItems = widget.vocabList.map((item) {
      return SwipeItem(
        content: Vocabulary(
          en: item["en"],
          vi: item["vi"],
          status: item["status"],
        ),
        likeAction: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Learned"),
            duration: Duration(milliseconds: 500),
          ));
        },
        nopeAction: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Still Learning"),
            duration: Duration(milliseconds: 500),
          ));
        },
      );
    }).toList();
    if (_isAuto) {
      timer = Timer.periodic(
        Duration(milliseconds: ((_flipDuration + _swipeDuration + 0.2) * 1000).toInt()),
        (timer) async {
          if (_currCard == widget.vocabList.length) timer.cancel();

          await _cardController.toggleCard().then((value) => Timer(Duration(milliseconds: (_swipeDuration * 1000).toInt()), () {
                _matchEngine!.currentItem?.like();
              }));
        },
      );
    }
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("${_currCard.toString()}/${_swipeItems.length}"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 5 * 3.5,
            child: SwipeCards(
              matchEngine: _matchEngine!,
              itemBuilder: (BuildContext context, int index) {
                return VocabSwipeCard(
                  controller: _cardController,
                  vi: _swipeItems[index].content.vi,
                  en: _swipeItems[index].content.en,
                  isFlipped: false,
                  isFavorite: (_swipeItems[index].content.status == "favorited"),
                  setFavorite: () {
                    setState(() {
                      if (_swipeItems[index].content.status == "favorited") {
                        _swipeItems[index].content.status = "unfavorite";
                      } else {
                        _swipeItems[index].content.status = "favorited";
                      }
                    });
                  },
                );
              },
              onStackFinished: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Stack Finished"),
                  duration: Duration(milliseconds: 500),
                ));
              },
              itemChanged: (SwipeItem item, int index) {
                setState(() {
                  _currCard += 1;
                });
              },
              upSwipeAllowed: false,
              fillSpace: true,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
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
                  onPressed: () {
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
            timer.cancel();
          } else {
            timer = Timer.periodic(
              Duration(milliseconds: ((_flipDuration + _swipeDuration + 0.2) * 1000).toInt()),
              (timer) async {
                if (_currCard == widget.vocabList.length) timer.cancel();

                await _cardController.toggleCard().then((value) => Timer(Duration(milliseconds: (_swipeDuration * 1000).toInt()), () {
                      _matchEngine!.currentItem?.like();
                    }));
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
