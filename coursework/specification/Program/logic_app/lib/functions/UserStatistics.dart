
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserStatistics extends ChangeNotifier{

  int id = 0; //key
  String userName = "root";
  int completedQuestionId = 0;
  int correct = 0; //0-wrong ; 1 - correct
  String completedDate = "19700101";
  int completedTime = 0; // time taken to answer question

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'completedQuestionId': completedQuestionId,
      'correct': correct,
      'completedDate': completedDate,
      'completedTime': completedTime
    };
  }

  void update(int completedQuestionId, int correct, String completedDate, int completedTime) {
    this.completedQuestionId = completedQuestionId;
    this.correct = correct;
    this.completedDate = completedDate;
    this.completedTime = completedTime;
  }
}