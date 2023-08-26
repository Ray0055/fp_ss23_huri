import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:logic_app/functions/QuestionsCard.dart';
import 'package:logic_app/providers/Providers.dart';
import 'package:tex_text/tex_text.dart';

final selectedIndexProvider = StateProvider<int?>((ref) => null);

class QuestionCardWidget extends ConsumerWidget {
  const QuestionCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int index = ref.watch(questionIndexProvider);
    int? selectedIndex = ref.watch(selectedIndexProvider);
    return FutureBuilder<QuestionCard?>(
      future: ref.watch(dataBaseProvider).getQuestionById(index),
      // your Future function here
      builder: (BuildContext context, AsyncSnapshot<QuestionCard?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          // Your main Widget here
          final currentQuestion = snapshot.data;
          if (currentQuestion != null) {
            return Card(
              elevation: 5.0,
              margin: EdgeInsets.all(20.0),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TexText(currentQuestion.question),
                    SizedBox(height: 20),
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
                          ref.read(selectedIndexProvider.notifier).state = i;
                        }
                            : null,
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            ref.read(questionIndexProvider.notifier).state--;
                            ref.watch(selectedIndexProvider.notifier).state = null;

                          },
                          child: Text("Last"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(questionIndexProvider.notifier).state++;
                            if (ref.read(questionIndexProvider.notifier).state > 7){
                              ref.read(questionIndexProvider.notifier).state=1;
                            }
                            ref.watch(selectedIndexProvider.notifier).state = null;

                          },
                          child: Text("Next"),
                        ),
                        IconButton(onPressed: (){
                          showModalBottomSheet<void>(context: context, builder: (BuildContext context){
                            return Container(
                              height: 200,
                              color: Colors.blue,
                              child: TexText(r"explanation $A\times B$")
                            );
                          });
                        }, icon: Icon(Icons.info))
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Text("No question found");
          }
        }
      },
    );
  }
}
