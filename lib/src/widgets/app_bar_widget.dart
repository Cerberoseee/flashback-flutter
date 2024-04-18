import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        "FlashBack",
        style: GoogleFonts.robotoCondensed(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFEEEEEE),
        ),
      ),
      backgroundColor: const Color(0xFF222831),
    );
  }
}
