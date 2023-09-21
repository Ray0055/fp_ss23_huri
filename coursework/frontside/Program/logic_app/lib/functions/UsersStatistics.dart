import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsersStatistics extends ChangeNotifier{

  int id = 0; //key
  String userName = "root";
  int totalCompletedQuestions = 0;
  int totalCorrectQuestions = 0; //0-wrong ; 1 - correct
  String completedDate = "19700101";
  int totalCompletedTime = 0; // time taken to answer question

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'totalCompletedQuestions': totalCompletedQuestions,
      'totalCorrectQuestions': totalCorrectQuestions,
      'completedDate': completedDate,
      'totalCompletedTime': totalCompletedTime
    };
  }

  void updateCompletedQuestion(int totalCompletedQuestions, int totalCorrectQuestions, String completedDate, int totalCompletedTime) {
    this.totalCompletedQuestions = totalCompletedQuestions;
    this.totalCorrectQuestions = totalCorrectQuestions;
    this.completedDate = completedDate;
    this.totalCompletedTime = totalCompletedTime;
  }
}