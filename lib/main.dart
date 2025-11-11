import 'package:flutter/material.dart';

// === PHASE 3 (Redesigned): THE APP'S STARTING POINT ===

void main() {
  runApp(CalculatorApp());
}

// === CONVERTED TO STATEFULWIDGET FOR THEME ===
class CalculatorApp extends StatefulWidget {
  @override
  _CalculatorAppState createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  // State for the theme, default to dark
  ThemeMode _themeMode = ThemeMode.dark;

  // Function to toggle the theme
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
      
      // === THEME DEFINITIONS ===
      themeMode: _themeMode, // Control the active theme

      // Light Theme
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
      ),

      // Dark Theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),

      // Pass the toggle function to the home page
      home: CalculatorHomePage(onThemeToggle: _toggleTheme),
    );
  }
}

// This is the main screen of our app (it's stateful)
class CalculatorHomePage extends StatefulWidget {
  // === NEW: ACCEPT THEME TOGGLE FUNCTION ===
  final Function() onThemeToggle;

  const CalculatorHomePage({Key? key, required this.onThemeToggle})
      : super(key: key);

  @override
  _CalculatorHomePageState createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage> {
  // === PHASE 5 (Redesigned): CALCULATOR LOGIC & STATE ===

  // State variables for the new two-line display
  String expression = ""; // Top line, e.g., "25 ÷ 8"
  String output = "0"; // Bottom line, e.g., "3.125" or current number

  // Internal state for calculations
  double num1 = 0.0;
  double num2 = 0.0;
  String operand = "";
  bool shouldResetOutput =
      false; // True if the next number should clear the display

  // --- Button Colors are now defined in the 'build' method ---

  // This function is the "brain" that handles all button presses
  buttonPressed(String buttonText) {
    setState(() {
      // --- Special Buttons (AC, +/-, %, DEL) ---

      // Check for "AC" or "C"
      if (buttonText == "AC" || buttonText == "C") {
        // If 'C' is shown (meaning output is not 0), just clear output
        // If 'AC' is shown (output is 0), clear everything
        if (output != "0" || expression.isNotEmpty) {
          output = "0"; // Clear current entry
          if (operand.isEmpty) {
            expression = ""; // If no operation was in progress, clear expression too
          }
          shouldResetOutput = false;
        } else {
          expression = ""; // Full reset
          num1 = 0.0;
          num2 = 0.0;
          operand = "";
          shouldResetOutput = false;
        }
      }
      // === LOGIC FOR "DEL" BUTTON ===
      else if (buttonText == "DEL") {
        if (output == "Error" || shouldResetOutput) {
          // If there's an error or we're on a result, "DEL" acts like "C"
          output = "0";
          shouldResetOutput = false;
        } else if (output != "0") {
          // Remove the last character
          output = output.substring(0, output.length - 1);
          // If we delete all characters, set back to "0"
          if (output.isEmpty) {
            output = "0";
          }
        }
      } else if (buttonText == "+/-") {
        if (output == "Error" || output == "0") return;
        // Multiply by -1 and format nicely
        double currentVal = double.parse(output) * -1;
        output =
            currentVal.toStringAsFixed(currentVal.truncateToDouble() == currentVal ? 0 : 2);
        output = _formatResult(output); // Use formatter
      } else if (buttonText == "%") {
        if (output == "Error") return;
        output = (double.parse(output) / 100).toString();
      }

      // --- Operator Buttons ---
      else if (buttonText == "+" ||
          buttonText == "-" ||
          buttonText == "×" ||
          buttonText == "÷") {
        if (output == "Error") return;

        // Handle chaining operations (e.g., 5 + 5 + ...)
        if (num1 != 0.0 && operand.isNotEmpty && !shouldResetOutput) {
          _performCalculation();
        }

        num1 = double.parse(output);
        operand = buttonText;
        expression = output + " " + operand;
        shouldResetOutput = true;
      }

      // --- Equals Button ---
      else if (buttonText == "=") {
        if (operand.isEmpty || shouldResetOutput) return;

        num2 = double.parse(output);
        expression = expression + " " + output;
        _performCalculation();
        operand = ""; // Reset operand after equals
      }

      // --- Number Buttons (0-9) ---
      else if (buttonText == ".") {
        if (output.contains(".")) return;
        if (shouldResetOutput) {
          output = "0.";
          shouldResetOutput = false;
        } else {
          output = output + ".";
        }
      } else {
        // This is a number
        if (output == "0" || shouldResetOutput) {
          output = buttonText;
          shouldResetOutput = false;
        } else {
          output = output + buttonText;
        }
      }
    });
  }

  // --- Helper function for calculation ---
  void _performCalculation() {
    String result;
    // num2 is always the current value in 'output'
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
    num1 = double.parse(output == "Error" ? "0" : output); // Store result in num1 for chaining
    shouldResetOutput = true;
    // We keep 'expression' as is until a new operation starts
  }

  // --- Helper function to remove trailing ".0" ---
  String _formatResult(String res) {
    if (res == "Error") return "Error";
    double val = double.parse(res);
    // Check if the number is an integer
    if (val == val.truncateToDouble()) {
      return val.toInt().toString(); // Return as integer
    } else {
      // If it's a decimal, return it
      return val.toString();
    }
  }

  // === PHASE 4 (Redesigned): THE CALCULATOR'S UI ===

  // --- Helper for round buttons (1-9, ops, etc.) ---
  Widget buildButton(
      String buttonText, Color backgroundColor, Color foregroundColor) {
    return Expanded(
      child: Padding(
        // Padding between buttons
        padding: const EdgeInsets.all(6.0),
        child: AspectRatio(
          aspectRatio: 1, // Makes it square, CircleBorder makes it circle
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              shape: CircleBorder(), // Makes it a circle
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

  // --- buildWideButton function has been REMOVED ---

  // This is the main build method that creates the UI
  @override
  Widget build(BuildContext context) {
    // Determine if we should show 'AC' (All Clear) or 'C' (Clear)
    final acText = (output == "0" && expression.isEmpty) ? "AC" : "C";

    // === START DYNAMIC THEME COLOR DEFINITIONS ===
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Define colors for buttons based on theme
    final Color darkGrey = isDark ? Color(0xFF333333) : Color(0xFFF2F2F2);
    final Color lightGrey = isDark ? Color(0xFFAFAFAF) : Color(0xFFDCDCDC);
    final Color orange = Color(0xFFFF9F0A);
    final Color red = Color(0xFFD44B4B);

    // Define colors for text based on theme
    final Color numBtnText = isDark ? Colors.white : Colors.black;
    final Color opBtnText = Colors.white; // Always white for orange/red buttons
    final Color otherBtnText = Colors.black; // Always black for light grey buttons
    
    // Define colors for display text
    final Color mainTextColor = isDark ? Colors.white : Colors.black;
    final Color expressionTextColor = isDark ? Colors.grey : Color(0xFF888888);
    // === END DYNAMIC THEME COLOR DEFINITIONS ===

    return Scaffold(
      // backgroundColor is set by the theme
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // === NEW THEME TOGGLE WIDGET ===
            Container(
              padding: EdgeInsets.only(top: 10),
              child: IconButton(
                icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
                onPressed: widget.onThemeToggle, // Call the function from parent
                color: mainTextColor,
                iconSize: 30,
              ),
            ),

            // === THE DISPLAY AREA ===
            Expanded(
              flex:
                  2, // Give a bit more space to the display (2 parts display, 3 parts buttons)
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                alignment: Alignment.bottomRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Top line (expression)
                    Text(
                      expression,
                      style: TextStyle(fontSize: 32, color: expressionTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10),
                    // Bottom line (main output)
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

            // === THE BUTTON AREA ===
            Expanded(
              flex: 3, // 3 parts buttons
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Row 1
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
                    // Row 2
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
                    // Row 3
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
                    // Row 4
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
                    // === MODIFIED ROW 5 ===
                    Expanded(
                      child: Row(
                        children: [
                          // New DEL button
                          buildButton("DEL", red, opBtnText),
                          // Standard "0" button
                          buildButton("0", darkGrey, numBtnText),
                          // Standard "." button
                          buildButton(".", darkGrey, numBtnText),
                          // Standard "=" button
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