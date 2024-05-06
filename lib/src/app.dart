import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/screens/authenticate/forgot_password/forgot_view.dart';
import 'package:flutter_final/src/screens/authenticate/login/login_view.dart';
import 'package:flutter_final/src/screens/authenticate/register/register_view.dart';
import 'package:flutter_final/src/screens/authenticate/verify_email/verify_view.dart';
import 'package:flutter_final/src/screens/communities/communities_search_view.dart';
import 'package:flutter_final/src/screens/communities/communities_view.dart';
import 'package:flutter_final/src/screens/home/home_view.dart';
import 'package:flutter_final/src/screens/vocabularies/add_new_topic.dart';
import 'package:flutter_final/src/screens/vocabularies/add_to_folder.dart';
import 'package:flutter_final/src/screens/vocabularies/detail_folder/detail_folder_view.dart';
import 'package:flutter_final/src/screens/vocabularies/detail_topic/detail_topic_view.dart';
import 'package:flutter_final/src/screens/vocabularies/detail_topic/edit_topic_collection_view.dart';
import 'package:flutter_final/src/screens/vocabularies/detail_topic/flashcard_vocab_view.dart';
import 'package:flutter_final/src/screens/vocabularies/detail_topic/leaderboard_view.dart';
import 'package:flutter_final/src/screens/vocabularies/detail_topic/topic_test/test_setup_view.dart';
import 'package:flutter_final/src/screens/vocabularies/detail_topic/topic_test/test_view.dart';
import 'package:flutter_final/src/screens/vocabularies/vocabularies_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger/logger.dart';

import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.settingsController, required this.logger});

  final SettingsController settingsController;
  final Logger logger;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
          ],
          onGenerateTitle: (BuildContext context) => AppLocalizations.of(context)!.appTitle,
          theme: ThemeData.dark().copyWith(
            colorScheme: ThemeData.dark().colorScheme.copyWith(
                  primary: const Color(0xFF76ABAE),
                  onPrimary: const Color(0xFF76ABAE),
                  primaryContainer: const Color(0xFF76ABAE),
                  onPrimaryContainer: const Color(0xFF76ABAE),
                ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ThemeData.dark().colorScheme.copyWith(
                  primary: const Color(0xFF76ABAE),
                  onPrimary: const Color(0xFF76ABAE),
                  primaryContainer: const Color(0xFF76ABAE),
                  onPrimaryContainer: const Color(0xFF76ABAE),
                ),
          ),
          debugShowCheckedModeBanner: false,
          onGenerateRoute: (RouteSettings routeSettings) {
            logger.i(routeSettings.name);
            if (routeSettings.name == '/home') return PageRouteBuilder(pageBuilder: (_, __, ___) => const HomeView());
            if (routeSettings.name == '/vocab') return PageRouteBuilder(pageBuilder: (_, __, ___) => const VocabView());
            if (routeSettings.name == '/community') return PageRouteBuilder(pageBuilder: (_, __, ___) => const CommunityView());
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case ForgotPasswordView.routeName:
                    return const ForgotPasswordView();
                  case VerifyEmailView.routeName:
                    return const VerifyEmailView();
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
                  case TestSetupView.routeName:
                    return TestSetupView(
                      vocabList: (routeSettings.arguments as Map)["vocabList"],
                      lastScore: (routeSettings.arguments as Map)["lastScore"],
                    );
                  case TestView.routeName:
                    return TestView(
                      vocabList: (routeSettings.arguments as Map)["vocabList"],
                      testType: (routeSettings.arguments as Map)["testType"],
                      answerType: (routeSettings.arguments as Map)["answerType"],
                      instantAnswer: (routeSettings.arguments as Map)["instantAnswer"],
                    );
                  case AddTopicView.routeName:
                    return const AddTopicView();
                  case LeaderboardView.routeName:
                    return const LeaderboardView();
                  case CommunitySearchView.routeName:
                    return const CommunitySearchView();
                  default:
                    // if (FirebaseAuth.instance.currentUser != null) return const HomeView();
                    return const AddToFolder("123");
                  // return const LoginView();
                }
              },
            );
          },
        );
      },
    );
  }
}
