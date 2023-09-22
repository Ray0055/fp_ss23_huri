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

  QuestionCard(
      {required this.id,
      required this.question,
      required this.options,
      required this.correctIndex,
      required this.createdTime,
      required this.modifiedTime,
      required this.completed,
      required this.information});

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
    List<String> optionsList = [];
    if (map['options'] is String) {
      List<String> result = ["true", "false"];// Check if 'options' is a String.
      //final optionsDecoded = jsonDecode(map['options']); // Decode the JSON string.
      optionsList = result; // Convert the dynamic list to a list of Strings.
    } else if (map['options'] is List) { // Optionally handle the case where 'options' is already a list.
      optionsList = List<String>.from(map['options']);
    }

    return QuestionCard(
        id: map['id'],
        question: map['question'],
        options: optionsList, // Use the decoded options list.
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
