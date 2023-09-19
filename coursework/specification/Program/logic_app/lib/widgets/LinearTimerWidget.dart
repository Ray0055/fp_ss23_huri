import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linear_timer/linear_timer.dart';
import 'package:flutter/material.dart';


class LinearTimerWidget extends StatefulWidget {
  const LinearTimerWidget({super.key});

  @override
  State<LinearTimerWidget> createState() => _LinearTimerWidget();
}

class _LinearTimerWidget extends State<LinearTimerWidget> with TickerProviderStateMixin {

  late LinearTimerController timerController = LinearTimerController(this);
  bool timerRunning = false;

  @override
  void dispose() {
    timerController.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (timerRunning) {
              timerController.stop();
              setState(() {
                timerRunning = false;
              });
            } else {
              timerController.reset();
              timerController.start();
              setState(() {
                timerRunning = true;
              });
            }
          },
          child: timerRunning?const Icon(Icons.stop):const Icon(Icons.timer),
        ),
        body: Center(
            child: LinearTimer(
              duration: const Duration(seconds: 5),
              controller: timerController,
              onTimerEnd: () {
                setState(() {
                  timerRunning = false;
                });
              },
            )
        )
    );
  }
}