
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logic_app/functions/PageRouter.dart';
import 'package:logic_app/functions/DatabaseHelper.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await DatabaseHelper.instance.database;
  runApp(
     ProviderScope(child:MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        primarySwatch: Colors.teal,

      ),
      routerConfig: router_config,
    );
  }
}

