import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

class QuestionCard  {
  final int id ;
  final String question ;
  final List<String> options ;
  final int correctIndex ;
  final String createdTime ;
  final String modifiedTime ;
  final int completed;

  QuestionCard({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.createdTime,
    required this.modifiedTime,
    required this.completed,
  });

  Map<String, Object> toMap() {
    return {
      'id': id,
      'question_content': question,
      'options': jsonEncode(options),
      'answer': correctIndex,
      'created_time': createdTime,
      'modified_time': modifiedTime,
      'completed':completed
    };
  }

  factory QuestionCard.fromMap(Map<String, dynamic> map) {
    return QuestionCard(
      id: map['id'],
      question: map['question'],
      options: List<String>.from(map['options']),
      correctIndex: map['correntIndex'],  // 注意这里是 'correntIndex'，确保与 JSON 匹配
      createdTime: map['createdTime'],
      modifiedTime: map['modifiedTime'],
      completed: map['completed'],
    );
  }
}

