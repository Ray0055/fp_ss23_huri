import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logic_app/widgets/QuestionWidget.dart';
import 'package:settings_ui/settings_ui.dart';
import '../providers/Providers.dart';

class DatabasePage extends ConsumerWidget {
  const DatabasePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("database"),
        automaticallyImplyLeading: true,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text("Synchronization"),
            tiles: [
              SettingsTile(
                leading: const Icon(Icons.upload),
                description: const Text("   Update your question to serverside"),
                title: TextButton(
                  child: const Text(
                    "Update questions",
                    style: TextStyle(fontSize: 17),
                  ),
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text("Update questions to database"),
                              content: const Text("Warning! It will overwrite database"),
                              actions: <Widget>[
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, 'Cancel');
                                    },
                                    child: const Text("Cancel")),
                                TextButton(
                                    onPressed: () async {
                                      ref.read(dataBaseProvider).syncDatabaseToServer();
                                      Navigator.pop(context, 'OK');
                                    },
                                    child: const Text("Confirm"))
                              ],
                            ));
                  },
                ),
              ),
              SettingsTile(
                leading: const Icon(Icons.cloud_upload),
                description: const Text("   Update your statistics to serverside"),
                title: TextButton(
                  child: const Text(
                    "Upload Statistics",
                    style: TextStyle(fontSize: 17),
                  ),
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text("Update statistics to serverside"),
                              actions: <Widget>[
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, 'Cancel');
                                    },
                                    child: const Text("Cancel")),
                                TextButton(
                                    onPressed: () async {
                                      ref.read(dataBaseProvider).syncUserStatisticsToServer();
                                      Navigator.pop(context, 'OK');
                                    },
                                    child: const Text("Confirm"))
                              ],
                            ));
                  },
                ),
              ),
              SettingsTile(
                  leading: const Icon(Icons.download),
                  description: const Text("   Get more questions from serverside."),
                  title: TextButton(
                    child: const Text(
                      "Get questions",
                      style: TextStyle(fontSize: 17),
                    ),
                    onPressed: () async {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text("Get questions from database"),
                                content: const Text("Warning! It will overwrite database"),
                                actions: <Widget>[
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 'Cancel');
                                      },
                                      child: const Text("Cancel")),
                                  TextButton(
                                      onPressed: () async {
                                        ref.read(dataBaseProvider).getDatabaseFromServerSide();
                                        ref.watch(questionIndexProvider.notifier).state = 1;
                                        await ref.refresh(questionsIdProvider.future);
                                        ref.read(dataBaseProvider).getAmount();
                                        ref.refresh(isValueSetProvider.notifier).state = false;
                                        ref.read(isFinishedProvider.notifier).state = false;
                                        Navigator.pop(context, 'OK');
                                      },
                                      child: const Text("Confirm"))
                                ],
                              ));
                    },
                  ))
            ],
          ),
          SettingsSection(
            title: const Text("Study Options"),
            tiles: [
              SettingsTile(
                  leading: const Icon(Icons.restart_alt),
                  description: const Text("   Reset all question history."),
                  title: TextButton(
                      child: const Text(
                        "Reset all questions",
                        style: TextStyle(fontSize: 17),
                      ),
                      onPressed: () async {
                        return showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text("Reset all questions"),
                                  content: const Text("Warning! It will reset all questions as uncompleted!"),
                                  actions: <Widget>[
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, 'Cancel');
                                        },
                                        child: const Text("Cancel")),
                                    TextButton(
                                        onPressed: () async {
                                          ref.watch(dataBaseProvider).setAllQuestionsUncompleted();
                                          ref.watch(questionIndexProvider.notifier).state = 1;
                                          await ref.refresh(questionsIdProvider.future);
                                          ref.read(dataBaseProvider).getAmount();
                                          ref.refresh(isValueSetProvider.notifier).state = false;
                                          ref.read(isFinishedProvider.notifier).state = false;
                                          ref.read(selectedIndexProvider.notifier).state = null;
                                          Navigator.pop(context, 'OK');
                                        },
                                        child: const Text("Confirm"))
                                  ],
                                ));
                      }))
            ],
          )
        ],
      ),
    );
  }
}
