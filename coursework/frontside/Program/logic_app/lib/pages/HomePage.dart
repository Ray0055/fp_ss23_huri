import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logic_app/providers/Providers.dart';
import 'package:logic_app/pages/QuizPage.dart';
import 'package:logic_app/pages/SettingsPage.dart';
import 'package:logic_app/pages/StatisticsPage.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);
  static List pages = [
    const QuizPage(),
    const StatisticsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(bottomBarProvider).selectedIndex;

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Statistics'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: index,
        selectedItemColor: Colors.amber[800],
        onTap: (index) {
          ref.watch(bottomBarProvider).onItemTapped(index);
        },
      ),
    );
  }
}
