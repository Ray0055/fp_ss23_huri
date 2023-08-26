import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tex_text/tex_text.dart';
class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text("Statistics"),),
        body: Column(
          children: [
            TexText(r"text $A \times B$")
          ],
        ),
        
      
    );
  }
}
