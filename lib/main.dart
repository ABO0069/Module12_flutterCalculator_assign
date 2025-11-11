import 'package:flutter/material.dart';
void main() {
  runApp(CalculatorApp());
}
class CalculatorApp extends StatefulWidget {
  @override
  _CalculatorAppState createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calculator',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode, 
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: CalculatorHomePage(onThemeToggle: _toggleTheme),
    );
  }
}

class CalculatorHomePage extends StatefulWidget {
  final Function() onThemeToggle;
  const CalculatorHomePage({Key? key, required this.onThemeToggle})
      : super(key: key);

  @override
  _CalculatorHomePageState createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage> {
  String expression = ""; 
  String output = "0"; 
  double num1 = 0.0;
  double num2 = 0.0;
  String operand = "";
  bool shouldResetOutput =
      false; 
  buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "AC" || buttonText == "C") {
        if (output != "0" || expression.isNotEmpty) {
          output = "0"; 
          if (operand.isEmpty) {
            expression = ""; 
          }
          shouldResetOutput = false;
        } else {
          expression = "";
          num1 = 0.0;
          num2 = 0.0;
          operand = "";
          shouldResetOutput = false;
        }
      }
      else if (buttonText == "DEL") {
        if (output == "Error" || shouldResetOutput) {
          output = "0";
          shouldResetOutput = false;
        } else if (output != "0") {
          output = output.substring(0, output.length - 1);
          if (output.isEmpty) {
            output = "0";
          }
        }
      } else if (buttonText == "+/-") {
        if (output == "Error" || output == "0") return;
        double currentVal = double.parse(output) * -1;
        output =
            currentVal.toStringAsFixed(currentVal.truncateToDouble() == currentVal ? 0 : 2);
        output = _formatResult(output); 
      } else if (buttonText == "%") {
        if (output == "Error") return;
        output = (double.parse(output) / 100).toString();
      }
      else if (buttonText == "+" ||
          buttonText == "-" ||
          buttonText == "×" ||
          buttonText == "÷") {
        if (output == "Error") return;
        if (num1 != 0.0 && operand.isNotEmpty && !shouldResetOutput) {
          _performCalculation();
        }
        num1 = double.parse(output);
        operand = buttonText;
        expression = output + " " + operand;
        shouldResetOutput = true;
      }
      else if (buttonText == "=") {
        if (operand.isEmpty || shouldResetOutput) return;
        num2 = double.parse(output);
        expression = expression + " " + output;
        _performCalculation();
        operand = ""; 
      }
      else if (buttonText == ".") {
        if (output.contains(".")) return;
        if (shouldResetOutput) {
          output = "0.";
          shouldResetOutput = false;
        } else {
          output = output + ".";
        }
      } else {
        if (output == "0" || shouldResetOutput) {
          output = buttonText;
          shouldResetOutput = false;
        } else {
          output = output + buttonText;
        }
      }
    });
  }
  void _performCalculation() {
    String result;
    num2 = double.parse(output);
    if (operand == "+") {
      result = (num1 + num2).toString();
    } else if (operand == "-") {
      result = (num1 - num2).toString();
    } else if (operand == "×") {
      result = (num1 * num2).toString();
    } else if (operand == "÷") {
      if (num2 == 0) {
        result = "Error";
      } else {
        result = (num1 / num2).toString();
      }
    } else {
      result = output;
    }
    output = _formatResult(result);
    num1 = double.parse(output == "Error" ? "0" : output); 
    shouldResetOutput = true;
  }

  String _formatResult(String res) {
    if (res == "Error") return "Error";
    double val = double.parse(res);
    if (val == val.truncateToDouble()) {
      return val.toInt().toString(); 
    } else {
      return val.toString();
    }
  }

  Widget buildButton(
      String buttonText, Color backgroundColor, Color foregroundColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: AspectRatio(
          aspectRatio: 1, 
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              shape: CircleBorder(),
            ),
            onPressed: () => buttonPressed(buttonText),
            child: Text(
              buttonText,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final acText = (output == "0" && expression.isEmpty) ? "AC" : "C";
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color darkGrey = isDark ? Color(0xFF333333) : Color(0xFFF2F2F2);
    final Color lightGrey = isDark ? Color(0xFFAFAFAF) : Color(0xFFDCDCDC);
    final Color orange = Color(0xFFFF9F0A);
    final Color red = Color(0xFFD44B4B);
    final Color numBtnText = isDark ? Colors.white : Colors.black;
    final Color opBtnText = Colors.white; 
    final Color otherBtnText = Colors.black; 
    final Color mainTextColor = isDark ? Colors.white : Colors.black;
    final Color expressionTextColor = isDark ? Colors.grey : Color(0xFF888888);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 10),
              child: IconButton(
                icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
                onPressed: widget.onThemeToggle, 
                color: mainTextColor,
                iconSize: 30,
              ),
            ),

            Expanded(
              flex:
                  2, 
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                alignment: Alignment.bottomRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      expression,
                      style: TextStyle(fontSize: 32, color: expressionTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        output,
                        style: TextStyle(
                            fontSize: 72,
                            color: mainTextColor,
                            fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: 3, 
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          buildButton(acText, lightGrey, otherBtnText),
                          buildButton("+/-", lightGrey, otherBtnText),
                          buildButton("%", lightGrey, otherBtnText),
                          buildButton("÷", orange, opBtnText),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          buildButton("7", darkGrey, numBtnText),
                          buildButton("8", darkGrey, numBtnText),
                          buildButton("9", darkGrey, numBtnText),
                          buildButton("×", orange, opBtnText),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          buildButton("4", darkGrey, numBtnText),
                          buildButton("5", darkGrey, numBtnText),
                          buildButton("6", darkGrey, numBtnText),
                          buildButton("-", orange, opBtnText),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          buildButton("1", darkGrey, numBtnText),
                          buildButton("2", darkGrey, numBtnText),
                          buildButton("3", darkGrey, numBtnText),
                          buildButton("+", orange, opBtnText),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          buildButton("DEL", red, opBtnText),
                          buildButton("0", darkGrey, numBtnText),
                          buildButton(".", darkGrey, numBtnText),
                          buildButton("=", orange, opBtnText),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}