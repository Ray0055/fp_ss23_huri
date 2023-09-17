import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/Providers.dart';

class DatabasePage extends ConsumerWidget {
  const DatabasePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text("database"),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () async {
                int? amount = await ref.watch(dataBaseProvider).getAmount();
                print("amount is ${amount}");
              },
              child: Text("Amount")),
          ElevatedButton(
              onPressed: () {
                // ref.watch(dataBaseProvider).addQuestions(questionCards);
              },
              child: Text("add")),
          ElevatedButton(
              onPressed: () {
                ref.watch(dataBaseProvider).clearTable();
              },
              child: Text("clear table")),
          ElevatedButton(
              onPressed: () => ref.watch(dataBaseProvider).deleteTable(),
              child: Text("delete table")),
          ElevatedButton(
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text("Get questions from database"),
                          content:
                              const Text("Warning! It will overwrite database"),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context, 'Cancel');
                                },
                                child: const Text("Cancel")),
                            TextButton(
                                onPressed: () async {
                                  ref
                                      .read(dataBaseProvider)
                                      .getDatabaseFromServerSide();

                                  Navigator.pop(context, 'OK');
                                },
                                child: const Text("Confirm"))
                          ],
                        ));
              },
              child: Text("GetData")),
          ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text("Update questions to database"),
                          content:
                              const Text("Warning! It will overwrite database"),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context, 'Cancel');
                                },
                                child: const Text("Cancel")),
                            TextButton(
                                onPressed: () async {
                                  ref
                                      .read(dataBaseProvider)
                                      .syncDatabaseToServer();
                                  Navigator.pop(context, 'OK');
                                },
                                child: const Text("Confirm"))
                          ],
                        ));
              },
              child: const Text("SendToServer")),
        ],
      ),
    );
  }
}
