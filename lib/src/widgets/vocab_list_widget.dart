import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

class VocabListWidget extends StatelessWidget {
  final String title;
  final String description;
  final Icon? icon;
  final String imgAvatar;
  final String userName;
  final Function onTap;
  final bool isDeletable;
  final Function(BuildContext)? deleteFunc;

  const VocabListWidget({
    this.title = "",
    this.description = "",
    this.icon,
    this.imgAvatar = "",
    this.userName = "",
    this.isDeletable = false,
    this.deleteFunc,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return isDeletable
        ? Slidable(
            key: const ValueKey(0),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: deleteFunc!,
                  backgroundColor: const Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                ),
              ],
            ),
            child: Card(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF3A3A3A),
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: InkWell(
                  onTap: () => onTap(),
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
                          maxLines: 2,
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
                              backgroundImage: imgAvatar != "" ? NetworkImage(imgAvatar) : const AssetImage(kIsWeb ? "images/default-avatar.png" : "assets/images/default-avatar.png") as ImageProvider,
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
              ),
            ),
          )
        : Card(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF3A3A3A),
                ),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: InkWell(
                onTap: () => onTap(),
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
                        maxLines: 2,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 12,
                            backgroundImage: imgAvatar != "" ? NetworkImage(imgAvatar) : const AssetImage(kIsWeb ? "images/default-avatar.png" : "assets/images/default-avatar.png") as ImageProvider,
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
            ),
          );
  }
}
