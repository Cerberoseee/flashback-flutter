import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

class VocabSwipeCard extends StatefulWidget {
  final String en, vi;
  final bool isFlipped;

  const VocabSwipeCard({
    super.key,
    required this.vi,
    required this.en,
    required this.isFlipped,
  });

  @override
  State<StatefulWidget> createState() => _VocabSwipeCardState();
}

class _VocabSwipeCardState extends State<VocabSwipeCard> {
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  @override
  Widget build(BuildContext context) {
    return FlipCard(
      fill: Fill.fillBack,
      speed: 200,
      side: !widget.isFlipped ? CardSide.FRONT : CardSide.BACK,
      front: Container(
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
                  widget.en,
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
