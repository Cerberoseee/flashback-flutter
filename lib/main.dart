import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'src/app.dart';
import 'package:flutter_final/firebase_options.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

Future<void> main() async {
  var logger = Logger();
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());
  WidgetsFlutterBinding.ensureInitialized();
  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAwQedtuCTitsAQ2RhFs5rLuqac8OYoeK0",
        authDomain: "plashcard2.firebaseapp.com",
        databaseURL: "https://plashcard2-default-rtdb.asia-southeast1.firebasedatabase.app",
        projectId: "plashcard2",
        storageBucket: "plashcard2.appspot.com",
        messagingSenderId: "34818372698",
        appId: "1:34818372698:web:00f70fa38d804196399463",
        measurementId: "G-28H83E6JHM",
      ),
    );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(
        settingsController: settingsController,
        logger: logger,
      ),
    ),
  );
}
