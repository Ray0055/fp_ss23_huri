import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logic_app/functions/PageRouter.dart';
import 'package:logic_app/functions/DatabaseHelper.dart';
import 'package:logic_app/providers/Providers.dart';
import 'package:logic_app/widgets/QuestionWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool("first_time") ?? true; // first time launch app or not
  if (isFirstTime){
    prefs.setBool('first_time', true);
  }

  runApp(
    ProviderScope(
      overrides: [
        questionsIdProvider.overrideWith((ref) => ref.read(dataBaseProvider).getUnansweredQuestions()),
        darkModeProvider.overrideWith((ref) => DarkMode()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DarkMode darkMode = ref.watch(darkModeProvider);

    return MaterialApp.router(
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal
      ),
      themeMode: darkMode.initialValue ?ThemeMode.dark : ThemeMode.light,
      routerConfig: router_config,
    );
  }
}
