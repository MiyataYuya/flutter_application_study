import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade100),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class DrawingArea {
  Offset point;
  Paint areaPaint;

  DrawingArea({required this.point, required this.areaPaint});
}

class MyCustomPainter extends CustomPainter {
  List<List<DrawingArea>> pointsList = [];
  MyCustomPainter({required this.pointsList});

  @override
  void paint(Canvas canvas, Size size) {
    for (List<DrawingArea> points in pointsList) {
      for (int i = 0; i < points.length - 1; i++) {
        if (points[i] != null && points[i + 1] != null) {
          canvas.drawLine(
              points[i].point, points[i + 1].point, points[i].areaPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? selectedImagePath; // 選択された画像のパス
  List<String> imagePaths = []; // 画像のリスト
  String? directory; // 選択されたディレクトリのパス

  List<DrawingArea> points = [];
  List<List<DrawingArea>> pointsList = [];

  void _selectImage(String imagePath) {
    setState(() {
      selectedImagePath = imagePath;
    });
  }

  Future<void> selectFolder() async {
    // 画像のあるフォルダを選択して画像パスのリストを作成。
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      Directory directory = Directory(selectedDirectory);
      List<String> tempImagePaths = [];

      await for (var entity in directory.list()) {
        if (entity is File &&
            ['.jpg', '.jpeg', '.png']
                .contains('.' + entity.path.split('.').last.toLowerCase())) {
          tempImagePaths.add(entity.path);
        }
      }
      setState(() {
        this.directory = selectedDirectory;
        imagePaths = tempImagePaths;
        selectedImagePath =
            tempImagePaths.isNotEmpty ? tempImagePaths[0] : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        leading: BackButton(),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: imagePaths.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => _selectImage(imagePaths[index]),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(File(imagePaths[index])),
                  ),
                );
              },
            ),
          ),
          Expanded(
              flex: 8,
              child: Column(
                children: [
                  Expanded(
                    flex: 6,
                    child: selectedImagePath == null
                        ? const Center(child: Text("No image selected."))
                        : GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                RenderBox renderBox =
                                    context.findRenderObject() as RenderBox;
                                points.add(DrawingArea(
                                  point: renderBox
                                      .globalToLocal(details.localPosition),
                                  areaPaint: Paint()
                                    ..strokeCap = StrokeCap.round
                                    ..isAntiAlias = true
                                    ..color = Colors.pink.shade200
                                    ..strokeWidth = 2.0,
                                ));
                              });
                            },
                            onPanEnd: (details) {
                              setState(() {
                                pointsList.add(List.from(points));
                                points.clear();
                              });
                            },
                            child:
                                Stack(alignment: Alignment.center, children: [
                              Image.file(File(selectedImagePath!)),
                              CustomPaint(
                                painter:
                                    MyCustomPainter(pointsList: pointsList),
                                size: Size.infinite,
                              )
                            ]),
                          ),
                  ),
                  Expanded(flex: 4, child: Text("Button"))
                ],
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: selectFolder,
        tooltip: 'select folder',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
