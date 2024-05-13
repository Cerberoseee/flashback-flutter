import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/services/user_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:flutter_final/src/widgets/app_bar_widget.dart';
import 'package:flutter_final/src/widgets/bottom_navi_widget.dart';


import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatefulWidget {
  SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late Map<String, dynamic> _currentUser;

  String avatarUrl = "";
  String email = "";
  String language = "";
  String userName = "Guest";
  bool _isLoading = false;

  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    fetchData();
    super.initState();
  }

  void fetchData() async {
    final logger = Logger();
    setState(() {
      _isLoading = true;
    });
    _currentUser = {
      'avatarUrl': "https://firebasestorage.googleapis.com/v0/b/plashcard2.appspot.com/o/origin.jpg?alt=media&token=d10294c0-e645-49b1-8efd-1afcd9a1b08b",
      'email': "test@example.com",
      'language': "Tiếng Việt",
      'name': "test",
      "status": "Unblock",
      "username": "test",
    };

    try {
      String? emailUser = FirebaseAuth.instance.currentUser?.email.toString();
      if (emailUser != null) {
        dynamic user = await getUserByEmail(emailUser);
        if (mounted) {
          setState(() {
            avatarUrl = user['avatarUrl'];
            userName = user['name'];
            email = user['email'];
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

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // setState(() {
      //   imageUrl = '';
      // });
      uploadImage(File(pickedFile.path));
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

                  const SizedBox(height: 20,),

                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(avatarUrl),
                      radius: 60,
                    ),
                  ),
                  const SizedBox(height: 12,),

                  InkWell(
                    child: TextButton(
                        onPressed: () {},
                        child: const Text("CHANGE PROFILE", style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                        )),
                  ),

                  const SizedBox(height: 30,),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Account",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 8,),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Username", style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  ),
                                  Text(userName, style: const TextStyle(
                                      fontSize: 16
                                  ),
                                  )
                                ],
                              ),
                              InkWell(
                                child: TextButton(
                                    onPressed: () {
                                      _showDialog(context, userName);
                                    },
                                    child: const Text("Edit", style: TextStyle(
                                        fontSize: 18
                                    ),
                                    )),
                              )
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
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Email", style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(email, style: const TextStyle(
                                    fontSize: 16
                                    ),
                                  )
                                ],
                              ),
                              InkWell(
                                child: TextButton(
                                    onPressed: () {
                                      _showDialog(context, email);
                                    },
                                    child: const Text("Edit", style: TextStyle(
                                        fontSize: 18
                                      ),
                                    )),
                              )
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

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Change password", style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  ),
                                ],
                              ),
                              InkWell(
                                child: TextButton(
                                    onPressed: () {},
                                    child: const Icon(Icons.arrow_forward)),
                              )
                            ],
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
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 8,),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Settings", style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  ),
                                ],
                              ),
                              InkWell(
                                child: TextButton(
                                    onPressed: () {},
                                    child: const Icon(Icons.arrow_forward)),
                              )
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

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Achievement", style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  ),
                                ],
                              ),
                              InkWell(
                                child: TextButton(
                                    onPressed: () {},
                                    child: const Icon(Icons.arrow_forward)),
                              )
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFbA3C3C),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign out', style: TextStyle(
                          fontSize: 18
                        ),),

                        onPressed: (){},
                      ),
                    ),
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
