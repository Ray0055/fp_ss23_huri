import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logic_app/providers/Providers.dart';

class TimerClock extends ChangeNotifier {
  bool isRunning = false;
  Timer? _timer;
  int _duration = 0;

  int get duration {
    return _duration;
  }

  void startTimer(int timerMaximum) {
    if (!isRunning) {
      isRunning = true;
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (_duration < timerMaximum) { // 在每次回调中都检查 _duration 是否小于 timerMaximum
          _duration++;
          notifyListeners();
        } else {
          stopTimer();
        }
      });
    }
  }


  void stopTimer() {
    if (isRunning) {
      _timer?.cancel();
      isRunning = false;
      notifyListeners();
    }
  }

  void resetTimer() {
    _timer?.cancel();
    _duration = 0;
    isRunning = false;
    notifyListeners();
  }

  String transformTimer(int milliseconds) {
    int seconds = milliseconds ~/ 10;
    int minute = seconds % 3600 ~/ 60;
    int second = seconds % 60;
    int millisecond = milliseconds % 10;
    return reformTimer(minute) + ":" + reformTimer(second) + "." + millisecond.toString();
  }

  String formatDuration(int durationIn100ms) {
    int totalSeconds = (durationIn100ms * 100) ~/ 1000;
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    String hoursStr = (hours < 10) ? '0$hours' : '$hours';
    String minutesStr = (minutes < 10) ? '0$minutes' : '$minutes';
    String secondsStr = (seconds < 10) ? '0$seconds' : '$seconds';

    return '$hoursStr hours $minutesStr min $secondsStr s';
  }

  void main() {
    print(formatDuration(3600)); // Should print "00 hours 06 min 00 s"
  }

  String reformTimer(int time) {
    return time < 10 ? "0" + time.toString() : time.toString();
  }
}
