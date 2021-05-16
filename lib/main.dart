import 'package:ObjectDetectionApp/HomePage.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

List<CameraDescription> cameraList;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameraList = await availableCameras();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Object Detection App',
      home: HomePage(),
    );
  }
}
