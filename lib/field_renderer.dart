import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widgetstest/shapes.dart';

//toscene using matrix is probably important
//probably change to a moveablecanvas w/ shape objects passed for rendering and coordinate processing or smth
class FieldDimensionsModel{
  static FieldDimensionsModel? globalDims;
  FieldDimensionsModel(this.jsonPath){
    readJson();
  }
  FieldDimensionsModel.create(this.jsonPath);
  static Future<FieldDimensionsModel> createDefaultInstance(String path) async {
    globalDims = FieldDimensionsModel.create(path);
    await globalDims!.readJson();
    return globalDims!;
  }
  final String jsonPath;
  String? imgPath;
  Offset? topLeftPixels;
  double? metersPerPixel;
  ValueNotifier<bool> isLoaded = .new(false);

  Future<void> readJson() async {
    final String rawData = await rootBundle.loadString(jsonPath);
    final fieldData = await json.decode(rawData);

    imgPath = fieldData['field_image'];

    double widthMeters = fieldData['field_size'][0].toDouble();
    double widthPixels = (fieldData['field_corners']['top_left'][0]-fieldData['field_corners']['bottom_right'][0]).toDouble();
    metersPerPixel = widthMeters/widthPixels;
    topLeftPixels = Offset(fieldData['field_corners']['top_left'][0].toDouble(),fieldData['field_corners']['top_left'][1].toDouble());
    isLoaded.value = true;
  }

  Offset convertToFRC(Offset pixelOffset){
    return (pixelOffset-topLeftPixels!)*metersPerPixel!;
  }
}

class FieldViewer extends StatefulWidget{
  const FieldViewer({super.key, required this.dimsModel, required this.shapesModel});

  final FieldDimensionsModel dimsModel;
  final ShapesModel shapesModel;
  @override
  State<FieldViewer> createState() => _FieldViewerState();
}

class _FieldViewerState extends State<FieldViewer>{
  late final ShapesModel shapeModel;
  late final FieldDimensionsModel dimsModel;
  late final List<Shape> shapeList;
  final controller = TransformationController();

  void updateState(){
    setState(() {
      
    });
  }
  @override
  void initState(){
    super.initState();
    dimsModel = widget.dimsModel;
    shapeModel = widget.shapesModel;
    shapeList = shapeModel.shapes;
    dimsModel.isLoaded.addListener(updateState);
    shapeModel.addListener(updateState);
  }

  @override 
  void dispose(){
    super.dispose();
    dimsModel.isLoaded.removeListener(updateState);
    shapeModel.removeListener(updateState);
  }

  @override 
  Widget build(BuildContext context){
    return (dimsModel.isLoaded.value) ? 
    InteractiveViewer(
      boundaryMargin: .all(double.infinity), //Come up with reasonable max
      clipBehavior: .none,
      transformationController: controller,
      child: Stack(children:[
        Image.asset(dimsModel.imgPath!),
        CustomPaint(painter:Painter(shapeList: shapeList)),
        for(Shape s in shapeList) ...s.pointList
      ])
    )
    : Container();
  }
}

class Painter extends CustomPainter{
  Painter({required this.shapeList});

  final List<Shape> shapeList;
  @override
  void paint(Canvas canvas, Size size) {
    for(Shape s in shapeList){
      s.paint(canvas, size);
    } 
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}