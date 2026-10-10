import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:widgetstest/field_renderer.dart';
import 'package:widgetstest/shapes.dart';
import 'package:widgetstest/zone_label.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget{
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: Scaffold(body: Homepage()),
      theme: .from(colorScheme: .fromSeed(seedColor: Colors.deepPurple))
    );
  }
}

class Homepage extends StatefulWidget{
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState(); 
}

class _HomepageState extends State<Homepage>{
  @override 
  void initState() {
    super.initState();
    FieldDimensionsModel.createDefaultInstance("assets/fields/Rebuilt2026.json");
    FieldDimensionsModel.globalDims!.isLoaded.addListener((){setState(() {
      print("uh");
    });});
  }

  @override 
  Widget build(BuildContext context) {
    if(!FieldDimensionsModel.globalDims!.isLoaded.value) return Container();
    final editor = FieldViewer(dimsModel: FieldDimensionsModel.globalDims!, shapesModel: ShapesModel.globalModel);
    final polyTest = Polygon([Offset(100,100),Offset(100,200),Offset(200,200)]);
    final circleTest = Circle(Offset(300,300),100);
    ShapesModel.globalModel..add(polyTest)..add(circleTest);

    return Stack(children:[
      editor,
      MultiSplitView(
        children: [
          Container(), // Transparent window for field
          makeSideBar(context)
        ],
      )
    ]);
  }

  Widget makeSideBar(BuildContext context){
    return Container(
      decoration: BoxDecoration(color:Colors.grey,borderRadius:.only(topLeft:Radius.circular(8),bottomLeft:Radius.circular(8))),
      child: Column(
        children: [
          ZoneLabel(shapeModel: ShapesModel.globalModel)
        ]
      )
    );
  }
}