import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerClock extends ChangeNotifier {
  bool isRunning = false;
  Timer? _timer;
  int _duration = 0;
  List<int> timeStamp = [];

  int get duration {
    return _duration;
  }

  void setDuration(int duration){
    this._duration = duration;
  }

  void startTimer() {
    if (!isRunning) {
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        _duration++;
        notifyListeners();
      });
      isRunning = true;
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
    timeStamp.add(_duration);
    _duration = 0;
    isRunning = false;
    notifyListeners();
  }


  String getMaximum() {
    List stamp = timeStamp;
    int max = 0;
    if (stamp.isEmpty) {
      return transformTimer(0);
    } else {
      for (int i = 0; i < stamp.length; i++) {
        if (stamp[i] > max) {
          max = stamp[i];
        }
      }
      return transformTimer(max);
    }
  }

  String getMinimum() {
    List stamp = timeStamp;

    if (stamp.isEmpty) {
      return transformTimer(0);
    } else {
      int min = 1000000;
      for (int i = 0; i < stamp.length; i++) {
        if (stamp[i] < min) {
          min = stamp[i];
        }
      }
      return transformTimer(min.toInt());
    }
  }

  String transformTimer(int milliseconds) {
    int seconds = milliseconds ~/ 10;
    int minute = seconds % 3600 ~/ 60;
    int second = seconds % 60;
    int millisecond = milliseconds % 10;
    return reformTimer(minute) +
        ":" +
        reformTimer(second) +
        "." +
        millisecond.toString();
  }

  String reformTimer(int time) {
    return time < 10 ? "0" + time.toString() : time.toString();
  }
}
