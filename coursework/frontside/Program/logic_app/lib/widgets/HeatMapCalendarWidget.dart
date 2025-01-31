import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import '../providers/Providers.dart';

class HeatMapCalendarWidget extends ConsumerWidget {
  const HeatMapCalendarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
        future: ref.watch(dataBaseProvider).computeAllDatesCompletedQuestions(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return HeatMap(
              datasets: snapshot.data ?? {},
              defaultColor: Colors.grey.shade300,
              colorMode: ColorMode.opacity,
              showText: false,
              scrollable: true,
              colorsets: {
                1: Colors.red,
                3: Colors.orange,
                5: Colors.yellow,
                7: Colors.green,
                9: Colors.blue,
                11: Colors.indigo,
                13: Colors.purple,
              },
              onClick: (value) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value.toString())));
              },
            );
          }
        });
  }
}
