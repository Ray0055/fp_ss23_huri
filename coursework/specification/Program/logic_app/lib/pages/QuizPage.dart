import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logic_app/functions/TimerClock.dart';
import 'package:logic_app/providers/Providers.dart';
import 'package:logic_app/widgets/QuestionWidget.dart';
import 'package:logic_app/functions/QuestionsCard.dart';
import 'package:logic_app/functions/CustomSearchDelegate.dart';
import 'package:showcaseview/showcaseview.dart';

class QuizPage extends ConsumerWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ShowCaseWidget(
        onFinish: () {
          ref.read(key3Provider.notifier).state++;
        },
        builder: Builder(
          builder: (context) => const QuizPageStatefulWidget(),
        ),
      ),
    );
  }
}

class QuizPageStatefulWidget extends ConsumerStatefulWidget {
  const QuizPageStatefulWidget({Key? key}) : super(key: key);

  @override
  QuizPageState createState() => QuizPageState();
}

class QuizPageState extends ConsumerState<QuizPageStatefulWidget> {
  @override
  void initState() {
    super.initState();
    if (ref.read(isFirstTimeProvider.notifier).state) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context).startShowCase([tutorialKey1, tutorialKey2]);
        ref.read(isFirstTimeProvider.notifier).state = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TimerClock timerClock = ref.watch(timerClockProvider);
    int timerMaximum = ref.watch(timerMaximumProvider.notifier).state;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Logic Quiz"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate: CustomSearchDelegate());
              },
              icon: Showcase(
                targetPadding: const EdgeInsets.all(10),
                targetShapeBorder: const CircleBorder(),
                key: tutorialKey1,
                description: "Search Question",
                child: const Icon(Icons.search),
              ))
        ],
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.list),
        ),
      ),
      body: Column(children: [
        Showcase(
            key: tutorialKey2,
            description: "Used Time",
            child: LinearProgressIndicator(
              value: timerClock.duration / timerMaximum,
              valueColor: AlwaysStoppedAnimation(Colors.green.shade400),
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            )),
        const QuestionCardWidget(),
        TextButton(
            onPressed: () {
              timerClock.startTimer();
            },
            child: const Text("Start")),
        TextButton(
            onPressed: () {
              timerClock.stopTimer();
              timerClock.resetTimer();
            },
            child: const Text("Stop")),
      ]),
    );
  }
}
