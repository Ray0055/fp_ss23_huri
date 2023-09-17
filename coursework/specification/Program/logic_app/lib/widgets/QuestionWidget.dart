import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:logic_app/functions/QuestionsCard.dart';
import 'package:logic_app/providers/Providers.dart';
import 'package:tex_text/tex_text.dart';

final selectedIndexProvider = StateProvider<int?>((ref) => null);
final questionIndexProvider = StateProvider((ref) => 0);

class QuestionCardWidget extends ConsumerWidget {
  const QuestionCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int index = ref.watch(questionIndexProvider);
    int? selectedIndex = ref.watch(selectedIndexProvider);
    return FutureBuilder<QuestionCard?>(
      future: ref.watch(dataBaseProvider).getUnansweredQuestion(),
      builder: (BuildContext context, AsyncSnapshot<QuestionCard?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          // Your main Widget here
          final currentQuestion = snapshot.data;

          if (currentQuestion != null) {
            return Column(
              children: [
                FutureBuilder(
                    future: ref.watch(dataBaseProvider).getAmount(),
                    builder:
                        (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          index == 0) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        if (currentQuestion != null) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Text.rich(
                              TextSpan(
                                text: "Question ${index}",
                                style: TextStyle(
                                  fontSize: 40,
                                ),
                                children: [
                                  TextSpan(
                                      text: "/${snapshot.data}",
                                      style: TextStyle(fontSize: 20))
                                ],
                              ),
                            ),
                          );
                        } else {
                          return const Text("No question found");
                        }
                      }
                    }),
                Card(
                  elevation: 15.0,
                  margin: const EdgeInsets.all(20.0),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TexText(currentQuestion.question,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 20.0)),
                        //question
                        const SizedBox(height: 20),
                        for (var i = 0; i < currentQuestion.options.length; i++)
                          ListTile(
                            leading: Icon(
                              selectedIndex == null
                                  ? Icons.circle
                                  : selectedIndex == i
                                      ? i == currentQuestion.correctIndex
                                          ? Icons.check_circle
                                          : Icons.cancel
                                      : i == currentQuestion.correctIndex
                                          ? Icons.check_circle
                                          : Icons.circle,
                              color: selectedIndex == null
                                  ? Colors.grey
                                  : selectedIndex == i
                                      ? i == currentQuestion.correctIndex
                                          ? Colors.green
                                          : Colors.red
                                      : i == currentQuestion.correctIndex
                                          ? Colors.green
                                          : Colors.grey,
                            ),
                            title: Text(currentQuestion.options[i]),
                            onTap: selectedIndex == null
                                ? () {
                                    ref
                                        .read(selectedIndexProvider.notifier)
                                        .state = i;

                                    // 更新数据库
                                    int newCompletedValue =
                                        (i == currentQuestion.correctIndex)
                                            ? 1
                                            : 0;
                                    var newQuestion = QuestionCard(
                                      id: currentQuestion.id,
                                      question: currentQuestion.question,
                                      options: currentQuestion.options,
                                      correctIndex:
                                          currentQuestion.correctIndex,
                                      createdTime: currentQuestion.createdTime,
                                      modifiedTime:
                                          currentQuestion.modifiedTime,
                                      completed: newCompletedValue,
                                    );

                                    ref
                                        .read(dataBaseProvider)
                                        .updateQuestionInDatabase(newQuestion);
                                  }
                                : null,
                          ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                onPressed: () {
                                  showModalBottomSheet<void>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                            height: 200,
                                            color: Colors.blue,
                                            child: TexText(
                                                r"explanation $A\times B$"));
                                      });
                                },
                                icon: Icon(Icons.info)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 20)),
                              onPressed: () {
                                ref
                                    .watch(selectedIndexProvider.notifier)
                                    .state = null;
                                if (ref.watch(questionIndexProvider) == 0) {
                                  ref
                                      .read(questionIndexProvider.notifier)
                                      .state = 0;
                                } else {
                                  ref
                                      .read(questionIndexProvider.notifier)
                                      .state--;
                                }
                              },
                              child: Text("Last"),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 20)),
                              onPressed: () async {
                                int? amount = await ref
                                    .watch(dataBaseProvider)
                                    .getAmount();
                                ref
                                    .read(questionIndexProvider.notifier)
                                    .state++;
                                if (ref
                                        .watch(questionIndexProvider.notifier)
                                        .state >
                                    amount) {
                                  ref
                                      .read(questionIndexProvider.notifier)
                                      .state = 1;
                                }
                                ref
                                    .watch(selectedIndexProvider.notifier)
                                    .state = null;
                              },
                              child: Text("Next"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          } else {
            return Text("No question found");
          }
        }
      },
    );
  }
}
