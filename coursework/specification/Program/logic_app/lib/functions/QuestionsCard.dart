import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

class QuestionCard {
  final int id;

  final String question;

  final List<String> options;

  final int correctIndex;

  final String createdTime;

  final String modifiedTime;

  final int completed;

  final String information;

  QuestionCard({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.createdTime,
    required this.modifiedTime,
    required this.completed,
    required this.information
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': jsonEncode(options),
      'correctIndex': correctIndex,
      'createdTime': createdTime,
      'modifiedTime': modifiedTime,
      'completed': completed,
      'information': information
    };
  }

  factory QuestionCard.fromMap(Map<String, dynamic> map) {
    return QuestionCard(
      id: map['id'],
      question: map['question'],
      options: (jsonDecode(map['options']) as List).cast<String>(),
      correctIndex: map['correctIndex'],
      createdTime: map['createdTime'],
      modifiedTime: map['modifiedTime'],
      completed: map['completed'],
      information: map['information']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': jsonEncode(options),
      'correctIndex': correctIndex,
      'createdTime': createdTime,
      'modifiedTime': modifiedTime,
      'completed': completed,
      'information': information
    };
  }
}
