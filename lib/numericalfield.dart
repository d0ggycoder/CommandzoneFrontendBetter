import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberTextField extends StatelessWidget {
  final num initialValue;
  final String label;
  final double height;
  final bool enabled;
  final ValueChanged<num?>? onSubmitted;
  final num arrowKeyIncrement;
  final num? minValue;
  final num? maxValue;
  final int precision;

  late final TextEditingController _controller;

  NumberTextField({
    super.key,
    required this.initialValue,
    required this.label,
    this.height = 42,
    this.onSubmitted,
    this.enabled = true,
    this.arrowKeyIncrement = 0.01,
    this.minValue,
    this.maxValue,
    this.precision = 3,
    TextEditingController? controller,
  }) {
    _controller = controller ?? TextEditingController();
    _controller.text = initialValue.toStringAsFixed(precision);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowUp): () {
            _submitIncrement(_controller.text, arrowKeyIncrement);
          },
          const SingleActivator(LogicalKeyboardKey.arrowDown): () {
            _submitIncrement(_controller.text, -arrowKeyIncrement);
          },
        },
        child: Focus(
          skipTraversal: true,
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              _onSubmitted(_controller.text);
            }
          },
          child: TextField(
            enabled: enabled,
            controller: _controller,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r'(^(-?)\d*\.?\d*)')),
            ],
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              labelText: label,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmitted(String val) {
    if (val.isEmpty) {
      onSubmitted?.call(null);
    } else {
      num parsed = num.parse(val);
      num clamped = min(max(parsed, minValue ?? double.negativeInfinity),
          maxValue ?? double.infinity);
      onSubmitted?.call(clamped);
    }
  }

  void _submitIncrement(String val, num increment){
    if (val.isEmpty){

    }
  }
}