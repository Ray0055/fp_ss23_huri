import 'package:logic_app/functions/QuestionsCard.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseHelper extends ChangeNotifier {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('quiz_app.db');
    return _database!;
  }
  
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  question_content TEXT,
  options TEXT,
  answer INTEGER,
  created_time TEXT,
  modified_time TEXT,
  completed INTEGER
)
''');
    await db.execute('''
CREATE TABLE users (
  id INTEGER,
  username TEXT,
  total_done INTEGER,
  total_correct INTEGER
)
''');
  }

  Future<void> addQuestions(List<dynamic> questions) async{
    final db = await database;
    for(int i=0; i < questions.length;i++){
    await db.insert('questions', questions[i].toMap(),conflictAlgorithm: ConflictAlgorithm.ignore);}
  }

  Future<void> clearTable() async {
    final db = await database;
    await db.delete('questions');
  }

  Future<void> deleteTable() async{
    String databasePath = await getDatabasesPath();
    String path = '$databasePath/quiz_app.db';

    await deleteDatabase(path);
  }

  Future<QuestionCard?> getQuestionById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'questions', // table name
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return QuestionCard(
        id: map['id'],
        question: map['question_content'],
        options: (jsonDecode(map['options']) as List).cast<String>(),
        correctIndex: map['answer'],
        createdTime: map['created_time'],
        modifiedTime: map['modified_time'],
        completed: map['completed']
      );
    }
  }

  Future<List<String>> getQuestionsByQuery(String query) async {
    final db = await database;

    // 这里假设您希望在问题内容中进行搜索。
    // 您也可以扩展这个查询来在其他字段中搜索。
    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: 'question_content LIKE ?',
      whereArgs: ['%$query%'],
    );

    return List.generate(maps.length, (i) {
      return maps[i]['question_content'];
    });
  }

  Future<int> getAmount() async{
    final db = await database;
    var x = await db.rawQuery("SELECT COUNT(*) FROM questions");
    int? count = Sqflite.firstIntValue(x);
    return count ??0;
  }

  Future<int> getFeatureCount() async {
    final db = await database;
    var x = await db.rawQuery('SELECT COUNT(*) FROM questions WHERE completed=3');
    int? count = Sqflite.firstIntValue(x);
    return count ?? 0;
  }

//Get database from server side
  Future<void> getDatabaseFromServerSide() async {
    final response = await http.get(Uri.parse("http://10.0.2.2:8080/api/questions"), headers: {'Accept': 'application/json'});
    List<dynamic> jsonList = jsonDecode(response.body);
    List<QuestionCard> questionCards = jsonList.map((e) => QuestionCard.fromMap(e)).toList();

    if (response.statusCode == 200) {
      await addQuestions(questionCards);
    } else {
      print("Error");

    }
  }

}


