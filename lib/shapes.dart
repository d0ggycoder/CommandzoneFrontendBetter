import 'package:flutter/material.dart';
import 'package:widgetstest/field_entry_utils.dart';
import 'package:widgetstest/field_renderer.dart';

//TODO: fix point shifting on resize
class PointModel extends ChangeNotifier{
  PointModel({this._off = Offset.zero});
  Offset _off;

  Offset get off => _off;
  set off(Offset newOff) {
    _off=newOff;
    notifyListeners();
  } 
}

class Point extends StatefulWidget{
  const Point({super.key,required this.model});
  
  final PointModel model;

  Offset get loc => FieldDimensionsModel.globalDims!.convertToFRC(model.off);
  double get x => loc.dx; 
  double get y => loc.dy;

  set loc(Offset newLoc) => model.off = loc;
  set x(double newx) => model.off = Offset(newx,y);
  set y(double newy) => model.off = Offset(x,newy);
  @override
  State<Point> createState() => _PointState();
}

class _PointState extends State<Point>{
  static const double POINT_RADIUS = 7; 
  late final PointModel model;

  void updateState(){
    setState((){});
  }
  @override
  void initState(){
    super.initState();
    model = widget.model;
    model.addListener(updateState);
  }
  @override 
  void dispose(){
    super.dispose();
    model.removeListener(updateState);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Positioned(
      left:model.off.dx - POINT_RADIUS,
      top:model.off.dy - POINT_RADIUS,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState((){
            model.off+=details.delta;
          });
        },
        child: Container(
          width:2*POINT_RADIUS,
          height:2*POINT_RADIUS,
          decoration: BoxDecoration(
            color: theme.primaryColorDark,
            shape: .circle,
            border: .all(color: theme.primaryColorLight)
          )
        )
      )
    );
  }
}

abstract class Shape{
  Shape(this.pointList);
  final List<Point> pointList;
  void paint(Canvas canvas, Size size);
  Widget buildEditorWidget();
  void addListener(void Function() listener);

  static final defaultFillPaint = Paint()
    ..color = Colors.blue.withAlpha(51)
    ..style = PaintingStyle.fill;
  
  static final defaultStrokePaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke;
}

class Polygon implements Shape{
  Polygon(List<Offset> points){
    pointList = [];
    for(Offset point in points){
      pointList.add(Point(model: PointModel(off: point)));
    }
  }
  @override
  late final List<Point> pointList;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(pointList.first.x, pointList.first.y);
    for(int i = 1; i < pointList.length;i++){
      path.lineTo(pointList[i].x, pointList[i].y);
    }
    path.close();
    
    canvas.drawPath(path, Shape.defaultFillPaint);
    canvas.drawPath(path, Shape.defaultStrokePaint);
  }

  @override
  void addListener(void Function() listener) {
    for(Point point in pointList){
      point.model.addListener(listener);
    }
  }

  @override
  Widget buildEditorWidget() {
    return Column(children: [
      for(Point point in pointList) pointEditorWidget(point.model)
    ],);
  }
}

// Should implement a slider bar
class Circle implements Shape{
  Circle(Offset center, double radius){
    _center = Point(model: PointModel(off: center));
    _radius = Point(model: PointModel(off: center+Offset(radius,0)));
    pointList = [_center,_radius];
    oldCenter=center;

    _center.model.addListener((){
      _radius.loc += _center.loc - oldCenter;
      oldCenter = _center.loc;
    });
  }
  @override
  late final List<Point> pointList;

  late final Point _center;
  late final Point _radius;

  late Offset oldCenter;

  Offset get center => _center.loc;
  double get radius => (_center.loc-_radius.loc).distance;

  set center(Offset newCenter){
    Offset delta = newCenter-center;
    
    _center.model._off=newCenter;
    _radius.loc+=delta;  // Update only once
  }

  set radius(double newRadius){
    Offset delta = _radius.loc - center;
    delta*=newRadius/radius;
    _radius.loc = center + delta;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(center,radius,Shape.defaultFillPaint);
    canvas.drawCircle(center, radius, Shape.defaultStrokePaint);
  }

  @override
  void addListener(void Function() listener) {
    for(Point point in pointList){
      point.model.addListener(listener);
    }
  }

  @override
  Widget buildEditorWidget(){
    return Column(children: [
      Slider(value: radius, onChanged: (value) => radius=value),
      pointEditorWidget(pointList.first.model)
    ],);
  }
} 

class ShapesModel extends ChangeNotifier{
  static final globalModel = ShapesModel();

  final List<Shape> shapes = [];
  void add(Shape shape){
    shapes.add(shape);
    notifyListeners();
  }
  void remove(Shape shape){
    shapes.remove(shape);
    notifyListeners();
  }
  Shape operator [](int i){
    return shapes[i];
  }
}


Widget pointEditorWidget(PointModel pointModel){
  return Row(children: [
    NumericalField(label: "X Position (M)",valueChanged: (newX){
      pointModel.off = Offset(newX?.toDouble()??pointModel.off.dx,pointModel.off.dy);
    }),
    NumericalField(label: "Y Position (M)",valueChanged: (newY){
      pointModel.off = Offset(pointModel.off.dx,newY?.toDouble()??pointModel.off.dy);
    }),
  ],);
}