import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logic_app/functions/TimerClock.dart';
import 'package:logic_app/providers/Providers.dart';
import 'package:logic_app/widgets/QuestionWidget.dart';
import 'package:logic_app/functions/CustomSearchDelegate.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getBool('first_time');
      if (value == true) {
        ShowCaseWidget.of(context).startShowCase([tutorialKey1, tutorialKey2]);
        debugPrint("if else : $value");
        prefs.setBool('first_time', false);
      }
    });
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
      ]),
    );
  }
}
