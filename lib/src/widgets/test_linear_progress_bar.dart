import 'package:flutter/material.dart';

const double _kMyLinearProgressIndicatorHeight = 6.0;

class TestLinearProgressBar extends LinearProgressIndicator implements PreferredSizeWidget {
  TestLinearProgressBar({
    Key? key,
    double? value,
    Color? backgroundColor,
    Animation<Color>? valueColor,
  }) : super(
          key: key,
          value: value,
          backgroundColor: backgroundColor,
          valueColor: valueColor,
        );

  @override
  final Size preferredSize = const Size(double.infinity, _kMyLinearProgressIndicatorHeight);
}
