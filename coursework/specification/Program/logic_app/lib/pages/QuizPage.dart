import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linear_timer/linear_timer.dart';
import 'package:logic_app/functions/TimerClock.dart';
import 'package:logic_app/providers/Providers.dart';
import 'package:logic_app/widgets/QuestionWidget.dart';
import 'package:logic_app/functions/QuestionsCard.dart';
import 'package:logic_app/functions/CustomSearchDelegate.dart';

class QuizPage extends ConsumerWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<QuestionCard> questionCards = [
      QuestionCard(
          id: 0,
          question: r"$P \rightarrow Q$ if P is true, Q is false",
          options: ["true", "false"],
          correctIndex: 1,
          createdTime: "createdTime",
          modifiedTime: "modifiedTime",
          completed: 3),
      QuestionCard(
          id: 1,
          question: r"$P \land Q$ if P is false and Q is true",
          options: ["true", "false"],
          correctIndex: 1,
          createdTime: "createdTime",
          modifiedTime: "modifiedTime",
          completed: 3),
      QuestionCard(
          id: 2,
          question: r"$P \lor Q$ if P is false and Q is false",
          options: ["true", "false"],
          correctIndex: 1,
          createdTime: "createdTime",
          modifiedTime: "modifiedTime",
          completed: 3),
      QuestionCard(
          id: 3,
          question: r"$\lnot P$ if P is true",
          options: ["true", "false"],
          correctIndex: 1,
          createdTime: "createdTime",
          modifiedTime: "modifiedTime",
          completed: 3),
      QuestionCard(
          id: 4,
          question: r"$P \oplus Q$ if P is true and Q is true",
          options: ["true", "false"],
          correctIndex: 1,
          createdTime: "createdTime",
          modifiedTime: "modifiedTime",
          completed: 3),
      QuestionCard(
          id: 5,
          question: r"$P \iff Q$ if P is true and Q is false",
          options: ["true", "false"],
          correctIndex: 1,
          createdTime: "createdTime",
          modifiedTime: "modifiedTime",
          completed: 3),
      QuestionCard(
          id: 6,
          question: r"$\lnot (P \land Q)$ if P is true and Q is false",
          options: ["true", "false"],
          correctIndex: 0,
          createdTime: "createdTime",
          modifiedTime: "modifiedTime",
          completed: 3),
      QuestionCard(
          id: 7,
          question: r"$\lnot P \lor Q$ if P is true and Q is true",
          options: ["true", "false"],
          correctIndex: 0,
          createdTime: "createdTime",
          modifiedTime: "modifiedTime",
          completed: 3),
      QuestionCard(
          id: 8,
          question: r"$P \rightarrow \lnot Q$ if P is false and Q is true",
          options: ["true", "false"],
          correctIndex: 0,
          createdTime: "createdTime",
          modifiedTime: "modifiedTime",
          completed: 3),
      QuestionCard(
          id: 9,
          question: r"$P \lor \lnot Q$ if P is false and Q is false",
          options: ["true", "false"],
          correctIndex: 0,
          createdTime: "createdTime",
          modifiedTime: "modifiedTime",
          completed: 3),
    ];
    TimerClock timerClock = ref.watch(timerClockProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Logic Quiz"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate: CustomSearchDelegate());
              },
              icon: const Icon(Icons.search))
        ],
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.list),
        ),
      ),
      body: Column(children: [
        LinearProgressIndicator(
          value:timerClock.duration/20,
          valueColor: AlwaysStoppedAnimation(Colors.green.shade400),
          minHeight: 10,
          borderRadius: BorderRadius.circular(10),
        ),
        const QuestionCardWidget(),
        TextButton(
            onPressed: (){
              timerClock.startTimer();
            }, child: Text("Start")),
        TextButton(onPressed: (){timerClock.stopTimer();timerClock.resetTimer();}, child: Text("Stop")),

      ]),
    );
  }
}
