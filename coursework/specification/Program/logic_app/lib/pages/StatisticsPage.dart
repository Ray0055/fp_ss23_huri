import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logic_app/providers/Providers.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:tex_text/tex_text.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistics"),
      ),
      body: SettingsList(sections: [
        SettingsSection(
          title: const Text(
            "Statistics",
            style: TextStyle(fontSize: 20),
          ),
          tiles: [
            SettingsTile(
                title: FutureBuilder(
              future: ref.read(dataBaseProvider).computeDailyAccuracy(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // 如果Future还在运行，显示一个加载指示器
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}'); // 如果我们遇到错误，显示它
                } else {
                  return Text(
                      'Daily Accuracy: ${snapshot.data}'); // 如果Future完成并且没有错误，显示正确率
                }
              },
            ))
          ],
        ),
      ]),
    );
  }
}
