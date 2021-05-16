import 'package:ObjectDetectionApp/main.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraImage camImg;
  CameraController camController;
  bool isWorking = false;
  String results = '';

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/mobilenet_v1_1.0_224.tflite",
      labels: "assets/mobilenet_v1_1.0_224.txt",
    );
  }

  initCam() {
    camController = CameraController(cameraList[0], ResolutionPreset.max);
    camController.initialize().then((value) {
      if (!mounted) {
        return 0;
      }
      setState(() {
        camController.startImageStream((imagesFromStream) => {
              if (!isWorking)
                {
                  //means the camera is not busy so we can take the camera
                  isWorking = true,
                  camImg = imagesFromStream,

                  runModelOnStreamedFrames(),
                }
            });
      });
    });
  }

  runModelOnStreamedFrames() async {
    if (camImg != null) {
      var recog = await Tflite.runModelOnFrame(
        bytesList: camImg.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: camImg.height,
        imageWidth: camImg.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );

      results = '';

      recog.forEach((response) {
        results += response["label"] +
            " " +
            (response["confidence"] as double).toStringAsFixed(2) +
            "\n\n";
      });

      setState(() {
        results;
      });

      isWorking = false;
    }
  }

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  void dispose() async {
    super.dispose();
    await Tflite.close();
    camController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 500,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black,
                  ),
                ),
                Center(
                  child: FlatButton(
                    onPressed: () {
                      initCam();
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 35),
                      height: 600,
                      width: MediaQuery.of(context).size.width,
                      child: camImg == null
                          ? Container(
                              height: 600,
                              width: MediaQuery.of(context).size.width,
                              child: Icon(
                                Icons.photo_camera_front,
                                color: Colors.blueAccent,
                                size: 40,
                              ),
                              
                            )
                          : AspectRatio(
                              aspectRatio: camController.value.aspectRatio,
                              child: CameraPreview(camController),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: Container(
                height: 30,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 20),
                child: SingleChildScrollView(
                  child: Text(
                    results,
                    style: TextStyle(
                      backgroundColor: Colors.black87,
                      fontSize: 30,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
