import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:logic_app/functions/DatabaseHelper.dart';
import 'package:logic_app/functions/UsersStatistics.dart';
import '../functions/TimerClock.dart';

final bottomBarProvider = ChangeNotifierProvider((ref) => BottomBar());
final darkModeProvider = ChangeNotifierProvider((ref) => DarkMode());
final dataBaseProvider = ChangeNotifierProvider((ref) => DatabaseHelper.instance);
final timerClockProvider = ChangeNotifierProvider((ref) => TimerClock());
final timerMaximumProvider = StateProvider<int>((ref) => 100);
final inputTextProvider = ChangeNotifierProvider((ref) => TextEditingController());
final isFirstTimeProvider = StateProvider((ref) => true);
final key3Provider = StateProvider((ref) => 0);
final usersStatisticsProvider = ChangeNotifierProvider((ref) => UsersStatistics());
final GlobalKey tutorialKey1 = GlobalKey();
final GlobalKey tutorialKey2 = GlobalKey();
final GlobalKey tutorialKey3 = GlobalKey();
final GlobalKey tutorialKey4 = GlobalKey();
final GlobalKey tutorialKey5 = GlobalKey();

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

String formatDuration(int durationIn100ms) {
  int totalSeconds = (durationIn100ms * 100) ~/ 1000;
  int hours = totalSeconds ~/ 3600;
  int minutes = (totalSeconds % 3600) ~/ 60;
  int seconds = totalSeconds % 60;

  String hoursStr = (hours < 10) ? '0$hours' : '$hours';
  String minutesStr = (minutes < 10) ? '0$minutes' : '$minutes';
  String secondsStr = (seconds < 10) ? '0$seconds' : '$seconds';

  return '$hoursStr h $minutesStr m $secondsStr s';
}





