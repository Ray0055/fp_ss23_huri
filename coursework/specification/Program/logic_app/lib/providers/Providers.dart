import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:logic_app/functions/DatabaseHelper.dart';
import 'package:logic_app/functions/QuestionsCard.dart';
import 'package:sqflite/sqflite.dart';

import '../functions/TimerClock.dart';

final bottomBarProvider = ChangeNotifierProvider((ref) => BottomBar());
final darkModeProvider = ChangeNotifierProvider((ref) => DarkMode());
final dataBaseProvider = ChangeNotifierProvider((ref) => DatabaseHelper.instance);
final timerClockProvider = ChangeNotifierProvider((ref) => TimerClock());

class BottomBar extends ChangeNotifier {
  int selectedIndex = 0;

  void onItemTapped(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}

class DarkMode extends ChangeNotifier{
  bool initialValue = false;
  void onTap(bool value){
    initialValue = value;
    notifyListeners();
  }
}

String getCurrentTimestamp() {
  final now = DateTime.now();
  String isoTime = now.toIso8601String();
  return isoTime;
}




