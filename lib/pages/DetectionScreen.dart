import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:ui/Model/ExerciseDataModel.dart';
import 'favorite.dart';

class DetectionScreen extends StatefulWidget {
  final ExerciseDataModel exerciseDataModel;

  DetectionScreen(this.exerciseDataModel, {super.key});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  CameraController? controller;
  bool isBusy = false;
  dynamic _scanResults;
  CameraImage? img;
  late PoseDetector poseDetector;
  Size? size;

  int lastDetectionTime = 0; // FPS limiter

  // Exercise counts
  int pushUpCount = 0;
  bool isLowered = false;
  int squatCount = 0;
  bool isSquatting = false;
  int plankToDownwardDogCount = 0;
  bool isInDownwardDog = false;
  int jumpingJackCount = 0;
  bool isJumpingJackOpen = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    final options = PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.base,
    );
    poseDetector = PoseDetector(options: options);

    // 🔹 Back camera
    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );

    controller = CameraController(
      backCamera,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    await controller!.initialize();
    if (!mounted) return;

    controller!.startImageStream((image) {
      if (!isBusy) {
        isBusy = true;
        img = image;
        doPoseEstimationOnFrame();
      }
    });

    setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    poseDetector.close();
    super.dispose();
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = controller!.description;
    final rotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation)!;
    final format = InputImageFormatValue.fromRawValue(image.format.raw)!;

    return InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  Future<void> doPoseEstimationOnFrame() async {
    if (img == null) {
      isBusy = false;
      return;
    }

    // FPS limiter: every 150ms
    if (DateTime.now().millisecondsSinceEpoch - lastDetectionTime < 150) {
      isBusy = false;
      return;
    }
    lastDetectionTime = DateTime.now().millisecondsSinceEpoch;

    final inputImage = _inputImageFromCameraImage(img!);
    if (inputImage != null) {
      _scanResults = await poseDetector.processImage(inputImage);

      if (_scanResults.isNotEmpty) {
        final pose = _scanResults[0];
        final landmarks = pose.landmarks;

        switch (widget.exerciseDataModel.type) {
          case 1:
            detectPushUp(landmarks);
            break;
          case 2:
            detectSquat(landmarks);
            break;
          case 3:
            detectPlankToDownwardDog(pose);
            break;
          case 4:
            detectJumpingJack(pose);
            break;
        }
      }
    }

    isBusy = false;
  }

  // ------------------ Exercise Detection ------------------
  void detectPushUp(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final ls = landmarks[PoseLandmarkType.leftShoulder];
    final rs = landmarks[PoseLandmarkType.rightShoulder];
    final le = landmarks[PoseLandmarkType.leftElbow];
    final re = landmarks[PoseLandmarkType.rightElbow];
    final lw = landmarks[PoseLandmarkType.leftWrist];
    final rw = landmarks[PoseLandmarkType.rightWrist];
    final lh = landmarks[PoseLandmarkType.leftHip];
    final rh = landmarks[PoseLandmarkType.rightHip];

    if ([ls, rs, le, re, lw, rw, lh, rh].contains(null)) return;

    double leftAngle = calculateAngle(ls!, le!, lw!);
    double rightAngle = calculateAngle(rs!, re!, rw!);
    double avg = (leftAngle + rightAngle) / 2;

    bool plank = calculateAngle(ls, lh!, rw) > 150;

    if (avg < 90 && plank) isLowered = true;
    else if (avg > 160 && isLowered) {
      pushUpCount++;
      isLowered = false;
      setState(() {}); // update UI on count
    }
  }

  void detectSquat(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final lh = landmarks[PoseLandmarkType.leftHip];
    final rh = landmarks[PoseLandmarkType.rightHip];
    final lk = landmarks[PoseLandmarkType.leftKnee];
    final rk = landmarks[PoseLandmarkType.rightKnee];
    final la = landmarks[PoseLandmarkType.leftAnkle];
    final ra = landmarks[PoseLandmarkType.rightAnkle];

    if ([lh, rh, lk, rk, la, ra].contains(null)) return;

    double left = calculateAngle(lh!, lk!, la!);
    double right = calculateAngle(rh!, rk!, ra!);
    double avg = (left + right) / 2;

    if (avg < 90 && !isSquatting) isSquatting = true;
    else if (avg > 160 && isSquatting) {
      squatCount++;
      isSquatting = false;
      setState(() {});
    }
  }

  void detectPlankToDownwardDog(Pose pose) {
    final lh = pose.landmarks[PoseLandmarkType.leftHip];
    final ls = pose.landmarks[PoseLandmarkType.leftShoulder];

    if (lh == null || ls == null) return;

    bool plank = (lh.y - ls.y).abs() < 30;
    bool upward = lh.y < ls.y - 50;

    if (upward && !isInDownwardDog) {
      isInDownwardDog = true;
    } else if (plank && isInDownwardDog) {
      plankToDownwardDogCount++;
      isInDownwardDog = false;
      setState(() {});
    }
  }

  void detectJumpingJack(Pose pose) {
    final la = pose.landmarks[PoseLandmarkType.leftAnkle];
    final ra = pose.landmarks[PoseLandmarkType.rightAnkle];
    final lw = pose.landmarks[PoseLandmarkType.leftWrist];
    final rw = pose.landmarks[PoseLandmarkType.rightWrist];
    final lh = pose.landmarks[PoseLandmarkType.leftHip];
    final rh = pose.landmarks[PoseLandmarkType.rightHip];

    if ([la, ra, lw, rw, lh, rh].contains(null)) return;

    double legSpread = (ra!.x - la!.x).abs();
    double arms = (lw!.y + rw!.y) / 2;
    double hip = (lh!.y + rh!.y) / 2;

    bool open = legSpread > 60 && arms < hip;

    if (open && !isJumpingJackOpen) isJumpingJackOpen = true;
    else if (!open && isJumpingJackOpen) {
      jumpingJackCount++;
      isJumpingJackOpen = false;
      setState(() {});
    }
  }

  double calculateAngle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    double ab = distance(a, b);
    double bc = distance(b, c);
    double ac = distance(a, c);
    return acos((ab * ab + bc * bc - ac * ac) / (2 * ab * bc)) * 180 / pi;
  }

  double distance(PoseLandmark p1, PoseLandmark p2) =>
      sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));

  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview (normal, not flipped)
          if (controller != null && controller!.value.isInitialized)
            Positioned.fill(
              child: CameraPreview(controller!),
            ),

          // Top bar
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: 50, left: 20, right: 20),
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: widget.exerciseDataModel.color,
                borderRadius: BorderRadius.circular(10),
              ),
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.exerciseDataModel.title,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Image.asset('assets/${widget.exerciseDataModel.image}', height: 50),
                ],
              ),
            ),
          ),

          // Bottom counter
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: widget.exerciseDataModel.color,
                borderRadius: BorderRadius.circular(50),
              ),
              width: 90,
              height: 90,
              child: Center(
                child: Text(
                  widget.exerciseDataModel.type == 1
                      ? "$pushUpCount"
                      : widget.exerciseDataModel.type == 2
                          ? "$squatCount"
                          : widget.exerciseDataModel.type == 3
                              ? "$plankToDownwardDogCount"
                              : "$jumpingJackCount",
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
