import 'package:flutter/material.dart';
import 'package:flutter_final/src/screens/authenticate/forgot-password/forgot_view.dart';
import 'package:flutter_final/src/screens/authenticate/login/login_view.dart';
import 'package:flutter_final/src/screens/authenticate/register/register_view.dart';
import 'package:flutter_final/src/screens/home/home_view.dart';
import 'package:flutter_final/src/screens/vocabularies/detail_folder/detail_folder_view.dart';
import 'package:flutter_final/src/screens/vocabularies/detail_topic/detail_topic_view.dart';
import 'package:flutter_final/src/screens/vocabularies/detail_topic/edit_topic_collection.dart';
import 'package:flutter_final/src/screens/vocabularies/detail_topic/flashcard_vocab_view.dart';
import 'package:flutter_final/src/screens/vocabularies/vocabularies_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.settingsController, required this.logger});

  final SettingsController settingsController;
  final logger;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) => AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          //themeMode: settingsController.themeMode,
          debugShowCheckedModeBanner: false,
          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            logger.i(routeSettings.name);
            if (routeSettings.name == '/home') return PageRouteBuilder(pageBuilder: (_, __, ___) => const HomeView());
            if (routeSettings.name == '/vocab') return PageRouteBuilder(pageBuilder: (_, __, ___) => const VocabView());
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case ForgotPasswordView.routeName:
                    return const ForgotPasswordView();
                  case RegisterView.routeName:
                    return const RegisterView();
                  case DetailTopicView.routeName:
                    return DetailTopicView(id: (routeSettings.arguments as Map)["id"]);
                  case DetailFolderView.routeName:
                    return DetailFolderView(id: (routeSettings.arguments as Map)["id"]);
                  case FlashcardVocabView.routeName:
                    return FlashcardVocabView(vocabList: (routeSettings.arguments as Map)["vocabList"]);
                  case EditTopicView.routeName:
                    return EditTopicView(id: (routeSettings.arguments as Map)["id"]);
                  default:
                    return const HomeView();
                }
              },
            );
          },
        );
      },
    );
  }
}
