import 'package:flutter/material.dart';
import 'package:widgetstest/shapes.dart';
import 'package:widgetstest/field_entry_utils.dart';

class ZoneLabel extends StatefulWidget{
  const ZoneLabel({super.key, required this.shapeModel});
  static int zoneCount = 1;
  final ShapesModel shapeModel;

  @override
  State<ZoneLabel> createState() => _ZoneLabelState();
}

class _ZoneLabelState extends State<ZoneLabel>{
  String zoneName = "Zone ${ZoneLabel.zoneCount++}";
  late final ShapesModel shapeModel;

  @override
  void initState() {
    super.initState();
    shapeModel = widget.shapeModel;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .all(8),
      child:ExpansionTile(
        title: TextField(
          controller:TextEditingController(text:zoneName)
        ),
        shape: RoundedRectangleBorder(borderRadius: .all(Radius.circular(8.0))),
        children: [
          for(Shape shape in shapeModel.shapes) shape.buildEditorWidget()
        ],
      )
    );
  }
}
