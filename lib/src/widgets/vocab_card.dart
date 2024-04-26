import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VocabSwipeCard extends StatefulWidget {
  final String en, vi;
  final Function setFavorite;
  final bool isFlipped, isFavorite;
  final FlipCardController controller;

  const VocabSwipeCard({
    super.key,
    required this.controller,
    required this.vi,
    required this.en,
    required this.isFlipped,
    required this.setFavorite,
    this.isFavorite = false,
  });

  @override
  State<StatefulWidget> createState() => _VocabSwipeCardState();
}

class _VocabSwipeCardState extends State<VocabSwipeCard> with TickerProviderStateMixin {
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      controller: widget.controller,
      fill: Fill.fillBack,
      speed: 200,
      side: !widget.isFlipped ? CardSide.FRONT : CardSide.BACK,
      front: Container(
        alignment: Alignment.center,
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Stack(
            children: [
              Container(
                alignment: Alignment.center,
                color: const Color(0xFF222831),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.en,
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        _speak(widget.en);
                      },
                      icon: const Icon(Icons.campaign),
                    ),
                    IconButton(
                      onPressed: () {
                        widget.setFavorite();
                      },
                      icon: Icon(widget.isFavorite ? Icons.star : Icons.star_border),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      back: Container(
        alignment: Alignment.center,
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
            alignment: Alignment.center,
            color: const Color(0xFF222831),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.vi,
                  style: const TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
