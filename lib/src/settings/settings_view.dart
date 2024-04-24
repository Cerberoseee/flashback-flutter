import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/services/user_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

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
  @override
  void initState() {
    // TODO: implement initState
    fetchData();
    super.initState();
  }

  void fetchData() async {
    final logger = Logger();
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
        Map<String, dynamic>? currentUser = await getCurrentUser(emailUser);
        // logger.e(currentUser);
        setState(() {
          _currentUser = currentUser!;
        });
      }
    } catch (e) {
      logger.e('Error fetching data: $e');
    }
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
      appBar: AppBar(
        surfaceTintColor: const Color(0xFF222831),
        backgroundColor: const Color(0xFF222831),
        title: Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              // Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                backgroundImage: NetworkImage(_currentUser['avatarUrl']),
                radius: 80,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "${_currentUser != null ? _currentUser['name'] ?? 'Unknown' : 'Unknown'}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "Thông tin cá nhân",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Container(
              alignment: Alignment.topLeft,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {},
                    style: ButtonStyle(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Name of User",
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${_currentUser != null ? _currentUser['name'] ?? 'Unknown' : 'Unknown'}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white))),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: ButtonStyle(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Email",
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${_currentUser['email']}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white))),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: ButtonStyle(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Language",
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${_currentUser['language']}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white))),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: ButtonStyle(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Change password",
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white))),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: ButtonStyle(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Lock your account",
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                  onPressed: signOut,
                  child: Text(
                    "Sign Out",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.purple),
                  )),
            ),
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
    );
  }
}
