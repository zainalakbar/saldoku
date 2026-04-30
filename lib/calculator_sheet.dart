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
      _num1 = double.parse(_output);
      _currentOperator = buttonText;
      _output = "0";
    } else if (buttonText == "=") {
      _num2 = double.parse(_output);
      if (_currentOperator == "+") _output = (_num1 + _num2).toString();
      if (_currentOperator == "-") _output = (_num1 - _num2).toString();
      if (_currentOperator == "x") _output = (_num1 * _num2).toString();
      if (_currentOperator == "/") _output = (_num1 / _num2).toString();
      
      _num1 = 0;
      _num2 = 0;
      _currentOperator = "";
      
      // Clean up integer results
      if (_output.endsWith(".0")) {
        _output = _output.substring(0, _output.length - 2);
      }
    } else {
      if (_output == "0") {
        _output = buttonText;
      } else {
        _output = _output + buttonText;
      }
    }
    setState(() {});
  }

  Widget _buildButton(String text, {Color? color, Color? textColor}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey.shade100,
            foregroundColor: textColor ?? const Color(0xFF0D1C44),
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
    return Container(
      padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kalkulator', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44))),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 18, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _output,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF0D1C44)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [_buildButton("7"), _buildButton("8"), _buildButton("9"), _buildButton("/", color: Colors.blue.shade100, textColor: const Color(0xFF1E60FE))]),
          Row(children: [_buildButton("4"), _buildButton("5"), _buildButton("6"), _buildButton("x", color: Colors.blue.shade100, textColor: const Color(0xFF1E60FE))]),
          Row(children: [_buildButton("1"), _buildButton("2"), _buildButton("3"), _buildButton("-", color: Colors.blue.shade100, textColor: const Color(0xFF1E60FE))]),
          Row(children: [_buildButton("C", color: Colors.red.shade50, textColor: Colors.red), _buildButton("0"), _buildButton("=", color: const Color(0xFF1E60FE), textColor: Colors.white), _buildButton("+", color: Colors.blue.shade100, textColor: const Color(0xFF1E60FE))]),
        ],
      ),
    );
  }
}
