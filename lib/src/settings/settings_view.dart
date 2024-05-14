import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/services/user_services.dart';
import 'package:flutter_final/src/settings/settings_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:flutter_final/src/widgets/app_bar_widget.dart';
import 'package:flutter_final/src/widgets/bottom_navi_widget.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatefulWidget {
  const SettingsView({super.key, required this.controller});

  final SettingsController controller;
  static const routeName = '/settings';

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String avatarUrl = "";
  String email = "";
  String language = "";
  String userName = "Guest";
  String fullName = "";
  bool _isLoading = false, _isAvatarLoading = false;

  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    fetchData();
    print(FirebaseAuth.instance.currentUser?.providerData);
    super.initState();
  }

  void fetchData() async {
    final logger = Logger();
    setState(() {
      _isLoading = true;
    });

    try {
      String? emailUser = FirebaseAuth.instance.currentUser?.email.toString();
      if (emailUser != null) {
        dynamic user = await getUserByEmail(emailUser);
        if (mounted) {
          setState(() {
            avatarUrl = user['avatarUrl'];
            userName = user['username'];
            email = user['email'];
            fullName = user['name'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      logger.e('Error fetching data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDialog(BuildContext context, String content) {
    controller.text = content;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Text'),
          content: TextField(
            controller: controller,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  bool checkUserProvider() {
    return FirebaseAuth.instance.currentUser?.providerData.firstWhereOrNull((e) => e.providerId == "google.com" || e.providerId == "facebook.com") != null;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    dynamic pickedFile;
    setState(() {
      _isAvatarLoading = true;
    });
    if (kIsWeb) {
      pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["png, jpeg"],
        allowMultiple: false,
      );
    } else {
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
    }
    if (pickedFile != null) {
      String url;
      if (kIsWeb) {
        url = await uploadImageWeb(pickedFile.files[0]) ?? "";
      } else {
        url = await uploadImage(File(pickedFile.path)) ?? "";
      }
      if (url != "") {
        await patchUser(FirebaseAuth.instance.currentUser!.uid, {"avatarUrl": url}).then((res) {
          if (res && mounted) {
            fetchData();
            setState(() {
              _isAvatarLoading = false;
            });
          }
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isAvatarLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),

                  GestureDetector(
                    onTap: _isAvatarLoading ? null : pickImage,
                    child: _isAvatarLoading
                        ? Container(
                            width: 120.0,
                            height: 120.0,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[400],
                            ),
                            child: const CircularProgressIndicator(),
                          )
                        : CircleAvatar(
                            backgroundImage: NetworkImage(avatarUrl),
                            radius: 60,
                          ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  // InkWell(
                  //   child: TextButton(
                  //     onPressed: () {},
                  //     child: const Text(
                  //       "CHANGE ACCOUNT PROFILE",
                  //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  //     ),
                  //   ),
                  // ),
                  Text(
                    fullName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Account",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    width: double.infinity,
                    // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF222831),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Username",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    userName,
                                    style: const TextStyle(fontSize: 16),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 0.5,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Email",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    email,
                                    style: const TextStyle(fontSize: 16),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 0.5,
                        ),
                        const Divider(
                          height: 1,
                          thickness: 0.5,
                        ),
                        Material(
                          child: Ink(
                            decoration: const BoxDecoration(
                              color: Color(0xFF222831),
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                            ),
                            child: InkWell(
                              onTap: checkUserProvider()
                                  ? null
                                  : () {
                                      Navigator.pushNamed(context, "/change-password");
                                    },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Change password",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: checkUserProvider() ? const Color(0xFFABABAB) : Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: checkUserProvider() ? const Color(0xFFABABAB) : Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "App",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    width: double.infinity,
                    // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF222831),
                    ),
                    child: Column(
                      children: [
                        Material(
                          child: Ink(
                            decoration: const BoxDecoration(
                              color: Color(0xFF222831),
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, "/detail-settings");
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Settings",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(Icons.arrow_forward),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // const Divider(
                        //   height: 1,
                        //   thickness: 0.5,
                        // ),
                        // Material(
                        //   child: Ink(
                        //     decoration: const BoxDecoration(
                        //       color: Color(0xFF222831),
                        //       borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                        //     ),
                        //     child: InkWell(
                        //       onTap: () {},
                        //       child: Container(
                        //         margin: const EdgeInsets.symmetric(vertical: 6),
                        //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        //         child: const Row(
                        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //           children: [
                        //             Column(
                        //               crossAxisAlignment: CrossAxisAlignment.start,
                        //               children: [
                        //                 Text(
                        //                   "Achievement",
                        //                   style: TextStyle(
                        //                     fontSize: 18,
                        //                     fontWeight: FontWeight.w500,
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //             Icon(Icons.arrow_forward),
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFbA3C3C),
                            backgroundColor: const Color(0xFF222831),
                            padding: const EdgeInsets.all(24),
                          ),
                          icon: const Icon(Icons.logout),
                          label: const Text(
                            'Sign out',
                            style: TextStyle(fontSize: 18),
                          ),
                          onPressed: () {
                            signOut();
                            Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
                          },
                        ),
                      ),
                    ],
                  )

                  // DropdownButton<ThemeMode>(
                  //   // Read the selected themeMode from the controller
                  //   //value: controller.themeMode,
                  //   // Call the updateThemeMode method any time the user selects a theme.
                  //   onChanged: controller.updateThemeMode,
                  //   items: const [
                  //     DropdownMenuItem(
                  //       value: ThemeMode.system,
                  //       child: Text('System Theme'),
                  //     ),
                  //     DropdownMenuItem(
                  //       value: ThemeMode.light,
                  //       child: Text('Light Theme'),
                  //     ),
                  //     DropdownMenuItem(
                  //       value: ThemeMode.dark,
                  //       child: Text('Dark Theme'),
                  //     )
                  //   ],
                  // ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNaviBar(index: 3),
    );
  }
}
