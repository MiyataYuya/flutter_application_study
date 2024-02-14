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
      List<FileSystemEntity> files = directory
          .listSync()
          .where((element) =>
              element is File &&
              ['.jpg', '.jpeg', '.png']
                  .contains('.' + element.path.split('.').last.toLowerCase()))
          .toList();
      setState(() {
        this.directory = selectedDirectory;
        imagePaths = files.map((e) => e.path).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        leading: BackButton(color: Colors.amber.shade900),
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
                    child: Image.asset(imagePaths[index]),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 8,
            child: Center(
              child: selectedImagePath == null
                  ? const Text("No image selected")
                  : Image.asset(selectedImagePath!),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: selectFolder,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
