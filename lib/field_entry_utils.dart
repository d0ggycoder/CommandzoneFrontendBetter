import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumericalField extends StatelessWidget{
  NumericalField({
    super.key,
    required this.label,
    this.valueChanged,
    this.defaultValue = 0.0,
    this.height = 42}
  ){
    controller = .new(text:"$defaultValue");
  }

  final String label;
  final num defaultValue; 
  final ValueChanged<num?>? valueChanged;
  final num height;
  late final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Expanded(child:SizedBox(
      height: height.toDouble(),
      child: Focus(
        onFocusChange: (hasFocus) {
          if(!hasFocus){
            _onSubmit(controller.text);
          } 
        },
        child: TextField(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            labelText: label,
            border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          controller:controller,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'(^(-?)\d*\.?\d*)'))]
        ),
      )
    ));
  }

  void _onSubmit(String val){
    if(val.isEmpty){
      valueChanged?.call(null);
    } else {
      valueChanged?.call(num.parse(val));
    } 
  }
}
