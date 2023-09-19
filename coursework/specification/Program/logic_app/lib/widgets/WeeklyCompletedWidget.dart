import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logic_app/functions/QuestionsStatistics.dart';
import 'package:logic_app/providers/Providers.dart';

final questionsStatisticsProvider = FutureProvider((ref) => QuestionsStatistics());

class WeeklyCompletedWidget extends ConsumerWidget {
  const WeeklyCompletedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
        future: ref.watch(dataBaseProvider).computeWeeklyCompletedQuestions(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    getDrawingVerticalLine: (value) {
                      if (value.toInt() == value) {
                        return const FlLine(
                          color: Colors.grey,
                          strokeWidth: 0.5,
                        );
                      }
                      return const FlLine(
                        color: Colors.transparent,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: const AxisTitles(
                        axisNameWidget: Text(
                          "Completed",
                          style: TextStyle(fontSize: 15),
                        ),
                        axisNameSize: 20),
                    bottomTitles: const AxisTitles(
                      axisNameWidget: Text(
                        "Last week date",
                        style: TextStyle(fontSize: 20),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    topTitles: AxisTitles(
                        sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        //only show integer value
                        if (value.toInt() == value) {
                          return Text(value.toInt().toString());
                        }
                        return const SizedBox.shrink();
                      },
                    )),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: const Color(0xff37434d),
                      width: 1,
                    ),
                  ),
                  minX: 1,
                  maxX: 7,
                  minY: 0,
                  maxY: 6,
                  lineBarsData: [
                    LineChartBarData(
                      spots: snapshot.data ?? [],
                      color: Colors.blue,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: true),
                    ),
                  ],
                ),
              ),
            );
          }

        });
  }
}
