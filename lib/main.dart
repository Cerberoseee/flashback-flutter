import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  var logger = Logger();
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());
  WidgetsFlutterBinding.ensureInitialized();
  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY'] ?? "",
      appId: dotenv.env['FIREBASE_APP_ID'] ?? "",
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? "",
      projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? "",
    ),
  ).onError((obj, error) {
    logger.e("Error initializing Firebase: ${error.toString()}");
    throw error;
  });
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

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
