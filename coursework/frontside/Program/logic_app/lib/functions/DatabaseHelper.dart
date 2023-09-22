import 'package:fl_chart/fl_chart.dart';
import 'package:logic_app/functions/QuestionsCard.dart';
import 'package:logic_app/functions/UsersHistory.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'UsersStatistics.dart';

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
  question TEXT,
  options TEXT,
  correctIndex INTEGER,
  createdTime TEXT,
  modifiedTime TEXT,
  completed INTEGER,
  information TEXT
)
''');
    await db.execute('''
CREATE TABLE usersHistory (
  id INTEGER,
  username TEXT,
  completedQuestionId INTEGER,
  correct INTEGER,
  completedDate TEXT,
  completedTime INTEGER
)
''');

    await db.execute('''
    CREATE TABLE usersStatistics (
  id INTEGER,
  username TEXT,
  totalCompletedQuestions INTEGER,
  totalCorrectQuestions INTEGER,
  completedDate TEXT,
  totalCompletedTime INTEGER
)
    ''');
    loadQuestionsFromJsonFile();
  }

  Future<void> loadQuestionsFromJsonFile() async {
    final String content = await rootBundle.loadString('assets/questions.json');
    final List<dynamic> questionsJson = jsonDecode(content);

    List<QuestionCard> questionCards = questionsJson.map((e) => QuestionCard.fromMap(e)).toList();
    await addQuestions(questionCards);
  }

  Future<void> addQuestions(List<dynamic> questions) async {
    final db = await database;
    for (int i = 0; i < questions.length; i++) {
      await db.insert('questions', questions[i].toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> addAnswerHistory(UsersHistory usersHistory) async {
    final db = await database;

    final questionId = usersHistory.completedQuestionId; // 请根据您的实际数据模型修改这一行

    final existingRecords = await db.query(
      'usersHistory',
      where: 'completedQuestionId = ?',
      whereArgs: [questionId],
    );

    if (existingRecords.isEmpty) {
      db.insert('usersHistory', usersHistory.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> addUsersStatistics(UsersStatistics usersStatistics) async {
    final db = await database;
    db.insert('usersStatistics', usersStatistics.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> clearTable() async {
    final db = await database;
    await db.delete('usersHistory');
    await db.delete('usersStatistics');
    await db.delete('questions');
  }

  Future<void> deleteTable() async {
    String databasePath = await getDatabasesPath();
    String path = '$databasePath/quiz_app.db';

    await deleteDatabase(path);
  }

  Future<QuestionCard?> getQuestionById(int? id) async {
    final db = await database;
    if (id == null) {
      return null;
    }
    final List<Map<String, dynamic>> maps = await db.query(
      'questions', // table name
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return QuestionCard(
          id: map['id'],
          question: map['question'],
          options: (jsonDecode(map['options']) as List).cast<String>(),
          correctIndex: map['correctIndex'],
          createdTime: map['createdTime'],
          modifiedTime: map['modifiedTime'],
          completed: map['completed'],
          information: map['information']);
    } else {
      print("Question with id = $id is not found.");
      return null;
    }
  }

  Future<String?> getInformationById(int? questionID) async {
    final db = await database;
    if (questionID == null) {
      return null;
    }
    final List<Map<String, dynamic>> map =
        await db.rawQuery("SELECT information FROM questions WHERE ID = ?", [questionID]);

    if (map.isNotEmpty) {
      return map.first['information'] as String?;
    }
    return null;
  }

  Future<List<int>?> getUnansweredQuestions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT id FROM questions WHERE completed = 2 ORDER BY id ASC');
    List<int> ids = maps.map((map) => map['id'] as int).toList();
    print("DatabaseHelper is $ids");
    if (ids.isNotEmpty) {
      return ids;
    }
    return null; // Return null if no unanswered question is found
  }

  Future<List<String>> getQuestionsByQuery(String query) async {
    final db = await database;

    // 这里假设您希望在问题内容中进行搜索。
    // 您也可以扩展这个查询来在其他字段中搜索。
    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: 'question LIKE ?',
      whereArgs: ['%$query%'],
    );

    return List.generate(maps.length, (i) {
      return maps[i]['question'];
    });
  }

  Future<int> getAmount() async {
    final db = await database;
    var x = await db.rawQuery("SELECT COUNT(*) FROM questions WHERE completed = 2 ");
    int? count = Sqflite.firstIntValue(x);
    return count ?? 0;
  }

  Future<int> getFeatureCount() async {
    final db = await database;
    var x = await db.rawQuery('SELECT COUNT(*) FROM questions WHERE completed=3');
    int? count = Sqflite.firstIntValue(x);
    return count ?? 0;
  }

//Get database from server side
  Future<void> getDatabaseFromServerSide() async {
    final response =
        await http.get(Uri.parse("http://10.0.2.2:8080/api/questions"), headers: {'Accept': 'application/json'});
    List<dynamic> jsonList = jsonDecode(response.body);
    List<QuestionCard> questionCards = jsonList.map((e) => QuestionCard.fromMap(e)).toList();

    if (response.statusCode == 200) {
      await addQuestions(questionCards);
    } else {
      print("Error");
    }
  }

  Future<void> syncDatabaseToServer() async {
    final db = await database;
    final List<Map<String, dynamic>> questionMaps = await db.query('questions');

    List<QuestionCard> questionCards = questionMaps.map((e) => QuestionCard.fromMap(e)).toList();
    List<Map<String, dynamic>> questionCardMaps = questionCards.map((e) => e.toJson()).toList();

    String jsonBody = jsonEncode(questionCardMaps);

    final response = await http.post(
      Uri.parse("http://10.0.2.2:8080/api/update_question"),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonBody,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("Successfully synced database to server.");
    } else {
      debugPrint("Error syncing database to server. Response code is ${response.statusCode} ");
    }
  }

  Future<void> syncUserStatisticsToServer() async {
    final db = await database;

    try {
      List<Map<String, dynamic>> result =
          await db.rawQuery('SELECT * FROM usersStatistics ORDER BY completedDate DESC LIMIT 1');

      if (result.isNotEmpty) {
        final Map<String, dynamic> maxIdRow = result.first;

        String jsonBody = jsonEncode(maxIdRow);
        final response = await http.post(
          Uri.parse("http://10.0.2.2:8080/api/update_statistics"),
          headers: {'Content-Type': 'application/json'},
          body: jsonBody,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          print("Successfully synced data to server.");
        } else {
          print("Error syncing data to server. Response code is ${response.statusCode}");
        }
      } else {
        print("No data found in usersStatistics table.");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  Future<void> updateQuestionInDatabase(QuestionCard updatedQuestion) async {
    final db = await database;
    await db.update(
      'questions',
      updatedQuestion.toMap(),
      where: 'id = ?',
      whereArgs: [updatedQuestion.id],
    );
  }

  Future<String> computeDailyAccuracy() async {
    final db = await database;

    // get today's data, transform it into string
    DateTime now = DateTime.now();
    String today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // search today's answered questions
    var completedToday =
        await db.rawQuery("SELECT COUNT(*) FROM questions WHERE completed != 2 AND DATE(modifiedTime) = ?", [today]);
    int? numberCompletedQuestionsToday = Sqflite.firstIntValue(completedToday);

    // search today's answered correctly questions
    var correctToday =
        await db.rawQuery("SELECT COUNT(*) FROM questions WHERE completed = 1 AND DATE(modifiedTime) = ?", [today]);
    int? numberCorrectQuestionsToday = Sqflite.firstIntValue(correctToday);

    // compute accuracy
    if (numberCompletedQuestionsToday == 0) {
      return "No questions completed today.";
    } else {
      double accuracy = (numberCorrectQuestionsToday! / numberCompletedQuestionsToday!) * 100;
      return "${accuracy.toStringAsFixed(2)}%";
    }
  }

  Future<int> computeDailyCompletedQuestions() async {
    final db = await database;
    DateTime now = DateTime.now();
    String today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    var completedToday =
        await db.rawQuery("SELECT COUNT(*) FROM questions WHERE completed != 2 AND DATE(modifiedTime) = ?", [today]);
    int numberCompletedQuestionsToday = Sqflite.firstIntValue(completedToday) ?? 0;

    return numberCompletedQuestionsToday;
  }

  Future<List<FlSpot>> computeWeeklyCompletedQuestions() async {
    final db = await database;
    List<FlSpot> weeklyData = [];

    for (int i = 6; i >= 0; i--) {
      DateTime day = DateTime.now().subtract(Duration(days: i));
      String date = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      var completedOnDay =
          await db.rawQuery("SELECT COUNT(*) FROM questions WHERE completed != 2 AND DATE(modifiedTime) = ?", [date]);
      int numberCompletedQuestionsOnDay = Sqflite.firstIntValue(completedOnDay) ?? 0;

      weeklyData.add(FlSpot((7 - i).toDouble(), numberCompletedQuestionsOnDay.toDouble()));
    }

    return weeklyData ?? [];
  }

  Future<Map<DateTime, int>> computeAllDatesCompletedQuestions() async {
    final db = await database;
    Map<DateTime, int> completedMap = {};

    // Query to get all completed questions with their modifiedTime
    final List<Map<String, dynamic>> result = await db.rawQuery(
        "SELECT COUNT(*) as count, DATE(modifiedTime) as date FROM questions WHERE completed != 2 GROUP BY DATE(modifiedTime)");

    // Loop through the result and populate the map
    for (var row in result) {
      String dateStr = row['date'];
      int count = row['count'];

      DateTime date = DateTime.parse(dateStr);
      completedMap[date] = count;
    }

    return completedMap ?? {};
  }

  Future<int> getTodayTotalTime() async {
    final db = await database;
    DateTime now = DateTime.now();
    String today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    List<Map> result = await db.rawQuery(
      'SELECT completedQuestionId, MAX(completedTime) as maxTime FROM usersHistory WHERE DATE(completedDate) = ? GROUP BY completedQuestionId',
      [today],
    );
    int totalTime = 0;
    for (var row in result) {
      totalTime += (row['maxTime'] as int);
    }
    return totalTime; //return time is /100 milliseconds
  }

  Future<int> getTodayCorrectQuestionsAmount() async {
    final db = await database;
    DateTime now = DateTime.now();
    String today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    var correctToday =
        await db.rawQuery("SELECT COUNT(*) FROM questions WHERE completed = 1 AND DATE(modifiedTime) = ?", [today]);
    int? numberCorrectQuestionsToday = Sqflite.firstIntValue(correctToday);
    return numberCorrectQuestionsToday ?? 0;
  }

  Future<void> setAllQuestionsUncompleted() async {
    final db = await database;
    await db.rawUpdate("UPDATE questions SET completed = ?", [2]);
  }
}
