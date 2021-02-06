import 'package:flutter/material.dart';
import 'package:calculator/constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculate',
      home: _CalculateState(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _CalculateState extends StatefulWidget {
  @override
  HomePage createState() => HomePage();
}

class HomePage extends State<_CalculateState> {
  String rs = "";
  String rstemp = "";
  List<String> rsArrayTemp = [];
  List<dynamic> rsArray = [];
  List<String> firstNumber = [];
  List<String> secondNumber = [];
  bool operator = false;

  int priority(String ope) {
    if (ope == 'x' || ope == '÷') {
      return 2;
    } else if (ope == '+' || ope == '-') {
      return 1;
    } else {
      return 0;
    }
  }

  double evaluate(double a, double b, String c) {
    switch (c) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case 'x':
        return a * b;
      default:
        return a / b;
    }
  }

  double formatNumber(String number) {
    return double.parse(number);
  }

  List<dynamic> eval(List<dynamic> infix) {
    List stack = [];
    List posfix = [];
    RegExp reg = RegExp(r'(\d)');
    for (var i = 0; i < infix.length; i++) {
      // print('---infix[$i]---: ${infix[i]}');
      if (reg.hasMatch(infix[i])) {
        /* Number */
        double val = formatNumber(infix[i]);
        if (i == infix.length - 1) {
          posfix.add(val);
          for (var j = stack.length - 1; j < stack.length; j--) {
            if (j >= 0) {
              // print(stack[j]);
              posfix.add(stack[j]);
              stack.removeLast();
            } else {
              break;
            }
          }
        } else if (posfix.isEmpty || stack.isNotEmpty) {
          posfix.add(val);
        }
      } else {
        /* evaluate */
        if (stack.isEmpty) {
          stack.add(infix[i]);
        } else {
          String t = '';
          dynamic v;
          stack.forEach((element) {
            if (priority(element) == priority(infix[i])) {
              t = '=';
              v = element;
            } else if (priority(element) > priority(infix[i])) {
              t = '>';
              v = element;
            } else {
              t = '<';
            }
            // print('${element},${infix[i]},$t');
          });
          if (t == '=') {
            posfix.add(v);
            stack.remove(v);
            stack.add(infix[i]);
          } else if (t == '>') {
            stack.add(infix[i]);
            posfix.add(v);
            stack.remove(v);
          } else {
            stack.add(infix[i]);
          }
          print('<<<<${stack}>>>>');
        }
      }
      // print('stack: $stack');
      // print('posfix: $posfix');
    }
    return posfix;
  }

  String posfixEval(List<dynamic> posfix) {
    List output = [];
    for (int i = 0; i < posfix.length; i++) {
      RegExp reg = RegExp(r'(^\d*\.?\d*)');
      if (posfix[i] == '+' ||
          posfix[i] == '-' ||
          posfix[i] == 'x' ||
          posfix[i] == '÷') {
        // evaluate
        output.add(posfix[i]);
      } else if (reg.hasMatch(posfix[i].toString())) {
        // Number
        output.add(posfix[i]);
      }
      if (output.length == 3 && output[2].runtimeType == String) {
        double a = output[0];
        double b = output[1];
        String c = output[2];
        output.clear();
        output.add(evaluate(a, b, c));
      } else if (output.length > 3 && output[2].runtimeType == double) {
        double a = output[1];
        double b = output[2];
        String c = output[3];
        output.removeRange(1, 4);
        output.add(evaluate(a, b, c));
      }
    }
    return output.join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Calculate'),
      // ),
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.only(
              right: 20,
            ),
            child: Text(
              rstemp,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Text(
              rs,
              style: TextStyle(
                fontSize: 64,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
            child: Container(
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  rowBtn([Button.zero, Button.mult, Button.divi, Button.ac]),
                  rowBtn([Button.one, Button.two, Button.three, Button.plus]),
                  rowBtn([Button.four, Button.five, Button.six, Button.minus]),
                  rowBtn(
                      [Button.seven, Button.eight, Button.nine, Button.equal]),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget rowBtn(List<String> val) {
    return Row(
      children: val
          .map(
            (e) => Container(
              child: Container(
                child: InkWell(
                  onTap: () {
                    setState(
                      () {
                        RegExp formatNumber = RegExp(r'(\d)');
                        if (e == Button.ac) {
                          /* AC */
                          rs = '';
                          rstemp = '';
                          rsArray.clear();
                          rsArrayTemp.clear();
                          firstNumber.clear();
                          secondNumber.clear();
                          operator = false;
                        } else if (e == Button.equal) {
                          rsArray.add(secondNumber.join());
                          rstemp = rsArray.join();
                          rs = posfixEval(eval(rsArray));
                          rsArray.clear();
                          rsArrayTemp.clear();
                          firstNumber.clear();
                          secondNumber.clear();
                          operator = false;
                          /* Equal */
                        } else if (formatNumber.hasMatch(e)) {
                          /* Number */
                          if (firstNumber.isEmpty) {
                            firstNumber.add(e);
                            rsArrayTemp.add(e);
                            rs = rsArrayTemp.join();
                          } else if (firstNumber.isNotEmpty &&
                              operator == false) {
                            firstNumber.add(e);
                            rsArrayTemp.add(e);
                            rs = rsArrayTemp.join();
                          } else if (firstNumber.isNotEmpty &&
                              operator == true) {
                            operator = true;
                            secondNumber.add(e);
                            rsArrayTemp.add(e);
                            rs = rsArrayTemp.join();
                          }
                        } else {
                          /* Operator */
                          if (e == Button.minus && firstNumber.isEmpty) {
                            firstNumber.add(e);
                            rsArrayTemp.add(e);
                            rs = rsArrayTemp.join();
                          } else if (firstNumber.isNotEmpty) {
                            if (operator == true) {
                              rsArray.add(secondNumber.join());
                            } else {
                              operator = true;
                              rsArray.add(firstNumber.join());
                            }
                            secondNumber.clear();
                            switch (e) {
                              case Button.plus:
                                rsArray.add(e);
                                rsArrayTemp.add(e);
                                break;
                              case Button.minus:
                                rsArray.add(e);
                                rsArrayTemp.add(e);
                                break;
                              case Button.mult:
                                rsArray.add('x');
                                rsArrayTemp.add(e);
                                break;
                              case Button.divi:
                                rsArray.add('÷');
                                rsArrayTemp.add('÷');
                                break;
                              default:
                            }
                            rs = rsArray.join();
                          }
                        }
                      },
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width / 6,
                    height: MediaQuery.of(context).size.width / 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        '$e',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
