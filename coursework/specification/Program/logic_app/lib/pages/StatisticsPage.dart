import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logic_app/providers/Providers.dart';
import 'package:fl_chart/fl_chart.dart';

import '../widgets/HeatMapCalendarWidget.dart';
import '../widgets/WeeklyCompletedWidget.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var inputText = ref.watch(inputTextProvider);

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Statistics"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder(
                      future: ref.read(dataBaseProvider).computeDailyAccuracy(),
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator(); // 如果Future还在运行，显示一个加载指示器
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}'); // 如果我们遇到错误，显示它
                        } else {
                          return Text(
                            'Daily Accuracy: ${snapshot.data}',
                            style: const TextStyle(fontSize: 17),
                          ); // 如果Future完成并且没有错误，显示正确率
                        }
                      },
                    ),
                    const Divider(height: 20, thickness: 1),
                    FutureBuilder(
                      future: ref.read(dataBaseProvider).computeDailyCompletedQuestions(),
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator(); // 如果Future还在运行，显示一个加载指示器
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}'); // 如果我们遇到错误，显示它
                        } else {
                          return Text('Daily Completed: ${snapshot.data}',
                              style: const TextStyle(fontSize: 17)); // 如果Future完成并且没有错误，显示正确率
                        }
                      },
                    ),
                    const Divider(
                      height: 20,
                      thickness: 1,
                    )
                  ],
                ),
              ),
              WeeklyCompletedWidget(),
              Padding(
                padding: EdgeInsets.all(16),
                child: HeatMapCalendarWidget(),
              ),
            ],
          ),
        ));
  }
}
