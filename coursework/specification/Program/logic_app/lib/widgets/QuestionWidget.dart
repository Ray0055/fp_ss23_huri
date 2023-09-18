import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logic_app/functions/QuestionsCard.dart';
import 'package:logic_app/providers/Providers.dart';
import 'package:tex_text/tex_text.dart';

final selectedIndexProvider = StateProvider<int?>((ref) => null);
final questionIndexProvider = StateProvider<int>((ref) => 1);
final numberQuestionsProvider = StateProvider<int>((ref) => 0);
final isValueSetProvider = StateProvider<bool>((ref) => false);

class QuestionCardWidget extends ConsumerWidget {
  const QuestionCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int index = ref.watch(questionIndexProvider);
    int? selectedIndex = ref.watch(selectedIndexProvider);
    bool isValueSet = ref.watch(isValueSetProvider.notifier).state;
    return FutureBuilder<QuestionCard?>(
      future: ref.watch(dataBaseProvider).getUnansweredQuestionByIndex(index),
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
                /// show current question index / amount of questions
                FutureBuilder(
                    future: ref.watch(dataBaseProvider).getAmount(),
                    builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && index == 0) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.data != null) {
                        if (!isValueSet && snapshot.data != null) {
                          Future(() {
                            ref.read(numberQuestionsProvider.notifier).state = snapshot.data!;
                            ref.refresh(isValueSetProvider.notifier).state = true;
                          });
                        }

                        // Use Future to ensure the state is updated after the widget tree has finished building
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
                                    text: "/${ref.read(numberQuestionsProvider.notifier).state}",
                                    style: TextStyle(fontSize: 20))
                              ],
                            ),
                          ),
                        );
                      } else {
                        return const Text("No question found");
                      }
                    }),

                /// question card
                Card(
                  elevation: 15.0,
                  margin: const EdgeInsets.all(20.0),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TexText(currentQuestion.question, style: const TextStyle(color: Colors.black, fontSize: 20.0)),
                        //question
                        const SizedBox(height: 20),
                        for (var i = 0; i < currentQuestion.options.length; i++)
                          ListTile(
                            // Option Widget
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
                                    ref.read(selectedIndexProvider.notifier).state = i;

                                    // Update completed value
                                    int newCompletedValue = (i == currentQuestion.correctIndex) ? 1 : 0;
                                    String currentTime = getCurrentTimestamp();
                                    print("current time is ${currentTime}");
                                    var newQuestion = QuestionCard(
                                      id: currentQuestion.id,
                                      question: currentQuestion.question,
                                      options: currentQuestion.options,
                                      correctIndex: currentQuestion.correctIndex,
                                      createdTime: currentQuestion.createdTime,
                                      modifiedTime: currentTime,
                                      completed: newCompletedValue,
                                    );

                                    ref.read(dataBaseProvider).updateQuestionInDatabase(newQuestion);
                                  }
                                : null,
                          ),

                        /// Explanation for the question
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
                                            child: TexText(r"explanation $A\times B$"));
                                      });
                                },
                                icon: Icon(Icons.info)),
                          ],
                        ),

                        /// Show last and next question
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(textStyle: const TextStyle(fontSize: 20)),
                              onPressed: () {
                                ref.watch(selectedIndexProvider.notifier).state = null;
                                if (ref.watch(questionIndexProvider) == 1) {
                                  ref.read(questionIndexProvider.notifier).state = 1;
                                } else {
                                  ref.read(questionIndexProvider.notifier).state--;
                                }
                              },
                              child: const Text("Last"),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(textStyle: const TextStyle(fontSize: 20)),
                              onPressed: () async {
                                int amount = ref.read(numberQuestionsProvider.notifier).state ?? 0;
                                ref.read(questionIndexProvider.notifier).state++;
                                print("amout is $amount");
                                print("current question index is ${ref.read(questionIndexProvider.notifier).state}");
                                if (ref.read(questionIndexProvider.notifier).state > amount) {
                                  ref.read(questionIndexProvider.notifier).state = amount;
                                }
                                ref.read(selectedIndexProvider.notifier).state = null;
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
            return const Text("You have finished all questions! ");
          }
        }
      },
    );
  }
}