import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VocabListWidget extends StatelessWidget {
  final String title;
  final String description;
  final Icon? icon;
  final String imgAvatar;
  final String userName;

  const VocabListWidget({
    this.title = "",
    this.description = "",
    this.icon,
    this.imgAvatar = "",
    this.userName = "",
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF3A3A3A),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon ?? Container(),
              Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                description,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 12, // Image radius
                    backgroundImage: imgAvatar != "" ? NetworkImage(imgAvatar) : const AssetImage("/images/default-avatar.png") as ImageProvider,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    userName,
                    style: GoogleFonts.roboto(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
