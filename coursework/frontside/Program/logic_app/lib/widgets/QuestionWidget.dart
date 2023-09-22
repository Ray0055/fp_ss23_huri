import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logic_app/functions/QuestionsCard.dart';
import 'package:logic_app/functions/UsersHistory.dart';
import 'package:logic_app/providers/Providers.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tex_text/tex_text.dart';
import 'package:logic_app/functions/TimerClock.dart';

final selectedIndexProvider = StateProvider<int?>((ref) => null);
final questionIndexProvider = StateProvider<int>((ref) => 1);
final questionIDProvider = StateProvider<int?>((ref) => 0);
final numberQuestionsProvider = StateProvider<int>((ref) => 0);
final isValueSetProvider = StateProvider<bool>((ref) => false);
final isFinishedProvider = StateProvider<bool>((ref) => false);
final questionsIdProvider = FutureProvider<List<int>?>((ref) async {
  return await ref.watch(dataBaseProvider).getUnansweredQuestions();
});
final isStudyingProvider = StateProvider((ref) => true);
final usersHistoryProvider = ChangeNotifierProvider((ref) => UsersHistory());

class QuestionCardWidget extends ConsumerWidget {
  const QuestionCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int? questionId = ref.watch(questionIDProvider);
    int questionIndex = ref.watch(questionIndexProvider);
    int? selectedIndex = ref.watch(selectedIndexProvider);
    bool isValueSet = ref.watch(isValueSetProvider.notifier).state;
    TimerClock timerClock = ref.read(timerClockProvider);
    UsersHistory usersHistory = ref.read(usersHistoryProvider);

    final AsyncValue<List<int>?> asyncValue = ref.watch(questionsIdProvider);

    /// ensure tutorial3,4,5 show after 1,2
    var key3State = ref.watch(key3Provider);
    if (key3State == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context).startShowCase([tutorialKey3, tutorialKey4, tutorialKey5]);
      });
      Future.delayed(Duration.zero, () {
        ref.read(key3Provider.notifier).state++;
      });
    }

    return asyncValue.when(
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
        data: (List<int>? questionIDList) {
          if (questionIndex == 1) {
            questionId = questionIDList?.first; //Set first question id
          }
          return Column(children: [
            /// Widget current question index / amount of questions
            FutureBuilder(
                future: ref.watch(dataBaseProvider).getAmount(),
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.data != null) {
                    if (snapshot.data == 0) {
                      Future(() {
                        ref.read(isFinishedProvider.notifier).state = true;
                      });
                      return const SizedBox.shrink();
                    } // finished all questions or not
                    if (!isValueSet && snapshot.data != null) {
                      // Use Future to ensure the state is updated after the widget tree has finished building
                      // Use isValueSet to keep amount of question
                      Future(() {
                        ref.read(numberQuestionsProvider.notifier).state = snapshot.data!;
                        ref.refresh(isValueSetProvider.notifier).state = true;
                      });
                    }

                    return Padding(padding: const EdgeInsets.all(15), child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        TextSpan(
                          text: "Question $questionIndex",
                          style: const TextStyle(
                            fontSize: 40,
                          ),
                          children: [
                            TextSpan(
                                text: "/${ref.read(numberQuestionsProvider.notifier).state}",
                                style: const TextStyle(fontSize: 25, color: Colors.teal))
                          ],
                        ),
                      ),
                    ),);
                  } else {
                    return const Text("No question found");
                  }
                }),

            /// Question Card Widget
            FutureBuilder<QuestionCard?>(
                future: ref.watch(dataBaseProvider).getQuestionById(questionId),
                builder: (BuildContext context, AsyncSnapshot<QuestionCard?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!ref.read(isFinishedProvider.notifier).state) {
                    final currentQuestion = snapshot.data;
                    if (currentQuestion != null && questionId != null) {
                      /// if question is completed, keep selected index
                      if (currentQuestion.completed != 2) {
                        debugPrint("Question is completed!");

                        // question is already completed
                        Future.delayed(Duration.zero, () async {
                          if (timerClock.isRunning) {
                            timerClock.stopTimer();
                            debugPrint("timer is stopped.");
                            debugPrint("duration is ${timerClock.duration}");

                            // update user statics and sync to database
                            usersHistory.update(
                                questionId!, currentQuestion.completed, getCurrentTimestamp(), timerClock.duration);
                            ref.read(dataBaseProvider).addAnswerHistory(usersHistory);
                            timerClock.resetTimer();
                          } else {
                            timerClock.stopTimer();
                          }
                        });
                        if (currentQuestion.completed == 1) {
                          // if answer is correct
                          Future.delayed(Duration.zero, () {
                            ref.read(selectedIndexProvider.notifier).state = currentQuestion.correctIndex;
                          });
                        } else {
                          // if answer is wrong
                          Future.delayed(Duration.zero, () {
                            ref.read(selectedIndexProvider.notifier).state =
                                (currentQuestion.correctIndex == 1) ? 0 : 1;
                          });
                          // only handle with binary answer!
                        }
                      } else {
                        // question is not completed

                        Future.delayed(Duration.zero, () async {
                          ref.read(selectedIndexProvider.notifier).state = null;
                          debugPrint("Question is not completed!");
                          if (timerClock.isRunning) {
                            debugPrint("Start timer clock - QuestionWidget");
                            timerClock.stopTimer();
                            timerClock.resetTimer();
                            timerClock.startTimer(ref.read(timerMaximumProvider.notifier).state);
                          } else {
                            timerClock.resetTimer();
                            timerClock.startTimer(ref.read(timerMaximumProvider.notifier).state);
                          }
                        });
                      }

                      return Card(
                          elevation: 15.0,
                          margin: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TexText(currentQuestion.question,
                                        style: const TextStyle(color: Colors.black, fontSize: 20.0)),
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
                                        title: Text(
                                          currentQuestion.options[i],
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        onTap: selectedIndex == null
                                            ? () {
                                                ref.read(isStudyingProvider.notifier).state = false;
                                                //if (timerClock.isRunning){timerClock.stopTimer();}

                                                ref.read(selectedIndexProvider.notifier).state = i;
                                                // Update completed value
                                                int newCompletedValue = (i == currentQuestion.correctIndex) ? 1 : 0;
                                                String currentTime = getCurrentTimestamp();

                                                var newQuestion = QuestionCard(
                                                    id: currentQuestion.id,
                                                    question: currentQuestion.question,
                                                    options: currentQuestion.options,
                                                    correctIndex: currentQuestion.correctIndex,
                                                    createdTime: currentQuestion.createdTime,
                                                    modifiedTime: currentTime,
                                                    completed: newCompletedValue,
                                                    information: currentQuestion.information);

                                                ref.read(dataBaseProvider).updateQuestionInDatabase(newQuestion);
                                              }
                                            : null,
                                      ),

                                    /// Information for the question
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Showcase(
                                          targetPadding: const EdgeInsets.all(3),
                                          targetShapeBorder: const CircleBorder(),
                                          key: tutorialKey5,
                                          description: "Show information of question",
                                          child: IconButton(
                                              onPressed: () {
                                                showModalBottomSheet<void>(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return SizedBox(
                                                        height: 200,
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(10),
                                                          child: FutureBuilder(
                                                              future: ref
                                                                  .read(dataBaseProvider)
                                                                  .getInformationById(questionId),
                                                              builder: (BuildContext context,
                                                                  AsyncSnapshot<String?> snapshot) {
                                                                if (snapshot.connectionState ==
                                                                    ConnectionState.waiting) {
                                                                  return const Center(
                                                                      child: CircularProgressIndicator());
                                                                } else if (snapshot.hasError) {
                                                                  return Text('Error: ${snapshot.error}');
                                                                } else {
                                                                  return SingleChildScrollView(
                                                                    child: TexText(
                                                                      "${snapshot.data}",
                                                                      style: const TextStyle(fontSize: 20, height: 1.5),
                                                                    ),
                                                                  );
                                                                }
                                                              }),
                                                        ),
                                                      );
                                                    });
                                              },
                                              icon: const Icon(Icons.info, color: Colors.teal)),
                                        )
                                      ],
                                    ),

                                    /// Show last and next question
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        /// Last Question Button

                                        TextButton(
                                          style: TextButton.styleFrom(textStyle: const TextStyle(fontSize: 20)),
                                          onPressed: () async {
                                            if (questionIndex == 1) {
                                              return showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                        content: const Text("No more questions!"),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(context, 'OK');
                                                              },
                                                              child: const Text("OK"))
                                                        ],
                                                      ));
                                            } else {
                                              debugPrint("$questionId");
                                              ref.read(questionIDProvider.notifier).state =
                                                  questionIDList?[questionIndex - 2];
                                              ref.read(questionIndexProvider.notifier).state--;
                                            }
                                          },
                                          child: Showcase(
                                            key: tutorialKey3,
                                            description: "Show last question",
                                            targetPadding: const EdgeInsets.all(5),
                                            child: const Text("Last"),
                                          ),
                                        ),

                                        /// Next Question Button
                                        TextButton(
                                          style: TextButton.styleFrom(textStyle: const TextStyle(fontSize: 20)),
                                          onPressed: () async {
                                            int amount = ref.read(numberQuestionsProvider.notifier).state;
                                            bool isFinished = ref.read(isFinishedProvider.notifier).state;

                                            // current question is not the last question
                                            if (questionIndex < amount) {
                                              ref.read(questionIDProvider.notifier).state =
                                                  questionIDList?[questionIndex];
                                              ref.read(questionIndexProvider.notifier).state++;

                                              ref.watch(selectedIndexProvider.notifier).state = null;
                                            }
                                            // current question is the last question and previous questions are completed
                                            else if (isFinished) {
                                              ref.read(questionIDProvider.notifier).state = null;
                                              return showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                        content: const Text("You have finished all questions!"),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(context, "Ok");
                                                              },
                                                              child: const Text("OK"))
                                                        ],
                                                      ));
                                            }
                                            // current question is the last question but previous questions are not completed
                                            else {
                                              return showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                        content: const Text("No more questions!"),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(context, 'OK');
                                                              },
                                                              child: const Text("OK"))
                                                        ],
                                                      ));
                                            }
                                          },
                                          child: Showcase(
                                            key: tutorialKey4,
                                            description: "Show next question",
                                            targetPadding: const EdgeInsets.all(5),
                                            child: const Text("Next"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ));
                    }
                  }
                  return const Text("Congratulation! You have finished all questions!", style: TextStyle(fontSize: 25));
                }),
          ]);
        });
  }
}
