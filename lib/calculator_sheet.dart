import 'package:flutter/material.dart';

class CalculatorSheet extends StatefulWidget {
  const CalculatorSheet({super.key});

  @override
  State<CalculatorSheet> createState() => _CalculatorSheetState();
}

class _CalculatorSheetState extends State<CalculatorSheet> {
  String _output = "0";
  String _currentOperator = "";
  double _num1 = 0;
  double _num2 = 0;

  void _buttonPressed(String buttonText) {
    if (buttonText == "C") {
      _output = "0";
      _num1 = 0;
      _num2 = 0;
      _currentOperator = "";
    } else if (buttonText == "+" || buttonText == "-" || buttonText == "/" || buttonText == "x") {
      _num1 = double.tryParse(_output) ?? 0;
      _currentOperator = buttonText;
      _output = "0";
    } else if (buttonText == "=") {
      _num2 = double.tryParse(_output) ?? 0;
      if (_currentOperator == "+") _output = (_num1 + _num2).toString();
      if (_currentOperator == "-") _output = (_num1 - _num2).toString();
      if (_currentOperator == "x") _output = (_num1 * _num2).toString();
      if (_currentOperator == "/") {
        if (_num2 == 0) {
          _output = "Error";
        } else {
          _output = (_num1 / _num2).toString();
        }
      }
      
      _num1 = 0;
      _num2 = 0;
      _currentOperator = "";
      
      // Clean up integer results
      if (_output.endsWith(".0")) {
        _output = _output.substring(0, _output.length - 2);
      }
    } else {
      if (_output == "0" || _output == "Error") {
        _output = buttonText;
      } else {
        _output = _output + buttonText;
      }
    }
    setState(() {});
  }

  Widget _buildButton(String text, {Color? color, Color? textColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine default colors if not provided
    Color buttonColor;
    Color buttonTextColor;
    
    if (text == "/" || text == "x" || text == "-" || text == "+") {
      buttonColor = color ?? (isDark ? const Color(0xFF1E60FE).withOpacity(0.15) : Colors.blue.shade100);
      buttonTextColor = textColor ?? (isDark ? const Color(0xFF1E90FF) : const Color(0xFF1E60FE));
    } else if (text == "C") {
      buttonColor = color ?? (isDark ? Colors.red.withOpacity(0.15) : Colors.red.shade50);
      buttonTextColor = textColor ?? (isDark ? Colors.redAccent : Colors.red);
    } else if (text == "=") {
      buttonColor = color ?? const Color(0xFF1E60FE);
      buttonTextColor = textColor ?? Colors.white;
    } else {
      buttonColor = color ?? (isDark ? Theme.of(context).colorScheme.surface : Colors.grey.shade100);
      buttonTextColor = textColor ?? Theme.of(context).colorScheme.onSurface;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: buttonTextColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 20),
            elevation: 0,
          ),
          onPressed: () => _buttonPressed(text),
          child: Text(text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 40),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300, 
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kalkulator', 
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold, 
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? Theme.of(context).colorScheme.surface : Colors.grey.shade100, 
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 18, color: isDark ? Colors.grey.shade400 : Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Theme.of(context).colorScheme.surface : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _output,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 48, 
                fontWeight: FontWeight.bold, 
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [_buildButton("7"), _buildButton("8"), _buildButton("9"), _buildButton("/")]),
          Row(children: [_buildButton("4"), _buildButton("5"), _buildButton("6"), _buildButton("x")]),
          Row(children: [_buildButton("1"), _buildButton("2"), _buildButton("3"), _buildButton("-")]),
          Row(children: [_buildButton("C"), _buildButton("0"), _buildButton("="), _buildButton("+")]),
        ],
      ),
    );
  }
}
