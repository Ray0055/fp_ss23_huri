import 'dart:convert';
import 'dart:math';
import 'package:dart_eval/dart_eval.dart';
import 'dart:io';

String generateComplexProp({int depth = 0, int maxDepth = 3}) {
  //could change maxDepth
  if (depth >= maxDepth) return (Random().nextBool()) ? 'A' : 'B';

  List<String> operators = ['AND', 'OR', 'NOT'];
  String operator = (operators..shuffle()).first;

  if (operator == 'NOT') {
    return 'NOT (${generateComplexProp(depth: depth + 1, maxDepth: maxDepth)})';
  } else {
    return '(${generateComplexProp(depth: depth + 1, maxDepth: maxDepth)}) '
        '$operator '
        '(${generateComplexProp(depth: depth + 1, maxDepth: maxDepth)})';
  }
}

String simplifyExpression(String expr) {
  final replacements = {
    'AND': r'\land',
    'OR': r'\lor',
    'NOT': r'\lnot',
    '(A)': r'A',
    '(B)': r'B',
    '((\lnot A))': r'\lnot A',
    '((\lnot B))': r'\lnot B',
  };

  String oldExpr;
  do {
    oldExpr = expr;
    replacements.forEach((key, value) {
      expr = expr.replaceAll(key, value);
    });
  } while (oldExpr != expr);

  return expr;
}

void main() {
  List<Map<String, dynamic>> questions = []; // To hold all the questions

  for (int i = 0; i < 200; i++) {
    // Generate 200 propositions
    String complexProposition = generateComplexProp();
    String latexProposition = simplifyExpression(complexProposition);

    Map<String, dynamic> question = {
      'id': i,
      'proposition': latexProposition,
      'evaluations': []
    };

    String exprStr = complexProposition;
    exprStr = exprStr
        .replaceAll('NOT ', 'not ')
        .replaceAll('AND', '&&')
        .replaceAll('OR', '||');

    List<Map<String, bool>> conditions = [
      {'A': true, 'B': true},
      {'A': true, 'B': false},
      {'A': false, 'B': true},
      {'A': false, 'B': false},
    ];
    var condition = (conditions..shuffle()).first;

    bool A = condition['A']!;
    bool B = condition['B']!;

    final program = """
        bool not(bool value) {
           if (value){
              return false;
            }else{
              return true;
            }
        }
  
        bool main() {
          bool A = $A;
          bool B = $B;
          return $exprStr;
        }
      """;

    try {
      final result = eval(program, function: 'main');
      question['evaluations'].add({
        'inputs': {'A': A, 'B': B},
        'result': result,
      });
    } catch (e) {
      print('Error occurred: $e');
    }

    questions.add(question);
  }

  String jsonString = jsonEncode({'questions': questions});
  File('propositions.json').writeAsStringSync(jsonString);
}
