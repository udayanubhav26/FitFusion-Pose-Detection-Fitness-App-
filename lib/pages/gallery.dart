import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image_picker/image_picker.dart';

class GalleryPosePage extends StatefulWidget {
  const GalleryPosePage({super.key});

  @override
  State<GalleryPosePage> createState() => _GalleryPosePageState();
}

class _GalleryPosePageState extends State<GalleryPosePage> {
  late ImagePicker imagePicker;
  File? _image;
  late PoseDetector poseDetector;
  var image;
  List<Pose> poses = [];
  String poseFeedback = "";

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();

    final options = PoseDetectorOptions(
        model: PoseDetectionModel.accurate,
        mode: PoseDetectionMode.single);

    poseDetector = PoseDetector(options: options);
  }

  @override
  void dispose() {
    poseDetector.close();
    super.dispose();
  }

  // Pick image from gallery
  Future<void> _imgFromGallery() async {
    XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      await _detectPose();
    }
  }

  // Pose detection
  Future<void> _detectPose() async {
    if (_image == null) return;

    // Decode image for drawing
    var bytes = await _image!.readAsBytes();
    image = await decodeImageFromList(bytes);

    InputImage inputImage = InputImage.fromFile(_image!);
    poses = await poseDetector.processImage(inputImage);

    if (poses.isNotEmpty) {
      poseFeedback = _analyzePose(poses.first);
    }

    setState(() {});
  }

  // Analyze pose and return feedback
  String _analyzePose(Pose pose) {
    PoseLandmark? leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    PoseLandmark? rightShoulder =
        pose.landmarks[PoseLandmarkType.rightShoulder];
    PoseLandmark? leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    PoseLandmark? rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    PoseLandmark? leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    PoseLandmark? rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    PoseLandmark? leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    PoseLandmark? rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    PoseLandmark? leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    PoseLandmark? rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
    PoseLandmark? leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    PoseLandmark? rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
    PoseLandmark? nose = pose.landmarks[PoseLandmarkType.nose];

    // Null check for all required landmarks
    if ([
      leftShoulder,
      rightShoulder,
      leftElbow,
      rightElbow,
      leftWrist,
      rightWrist,
      leftHip,
      rightHip,
      leftKnee,
      rightKnee,
      leftAnkle,
      rightAnkle,
      nose
    ].contains(null)) {
      return "Full body not detected. Make sure hands and feet are visible.";
    }

    // Calculate angles
    double leftArmAngle = _calculateAngle(leftWrist!, leftElbow!, leftShoulder!);
    double rightArmAngle = _calculateAngle(rightWrist!, rightElbow!, rightShoulder!);
    double leftLegAngle = _calculateAngle(leftHip!, leftKnee!, leftAnkle!);
    double rightLegAngle = _calculateAngle(rightHip!, rightKnee!, rightAnkle!);

    // Pose checks
    bool armsStraight = (leftArmAngle > 160 && leftArmAngle < 200) &&
        (rightArmAngle > 160 && rightArmAngle < 200);
    bool legsStraight = (leftLegAngle > 160 && leftLegAngle < 200) &&
        (rightLegAngle > 160 && rightLegAngle < 200);
    bool headUp = nose!.y < leftShoulder.y && nose.y < rightShoulder.y;

    // Feedback logic
    if (!armsStraight) return "Try straightening your arms more.";
    if (!legsStraight) return "Keep your legs extended.";
    if (!headUp) return "Lift your head slightly.";
    return "Perfect! Pose looks great!";
  }

  double _calculateAngle(PoseLandmark first, PoseLandmark mid, PoseLandmark last) {
    double radians =
        atan2(last.y - mid.y, last.x - mid.x) - atan2(first.y - mid.y, first.x - mid.x);
    return radians.abs() * 180 / pi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: image != null
                  ? FittedBox(
                      child: SizedBox(
                        width: image.width.toDouble(),
                        height: image.height.toDouble(),
                        child: CustomPaint(
                          painter: PosePainter(image, poses),
                        ),
                      ),
                    )
                  : const Center(
                      child: Text(
                        "Select an image from gallery",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
            ),
          ),
          if (poseFeedback.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                poseFeedback,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ElevatedButton.icon(
              onPressed: _imgFromGallery,
              icon: const Icon(Icons.photo),
              label: const Text("Pick from Gallery"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                backgroundColor: Colors.limeAccent,
                foregroundColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  final dynamic image;
  final List<Pose> poses;
  PosePainter(this.image, this.poses);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());

    Paint leftPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    Paint rightPaint = Paint()
      ..color = Colors.deepPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    Paint dotPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;

    for (var pose in poses) {
      // Draw landmarks
      for (var landmark in pose.landmarks.values) {
        canvas.drawCircle(Offset(landmark.x, landmark.y), 3, dotPaint);
      }

      void drawLine(PoseLandmarkType a, PoseLandmarkType b, Paint paint) {
        final l1 = pose.landmarks[a];
        final l2 = pose.landmarks[b];
        if (l1 != null && l2 != null) {
          canvas.drawLine(Offset(l1.x, l1.y), Offset(l2.x, l2.y), paint);
        }
      }

      // Arms
      drawLine(PoseLandmarkType.leftWrist, PoseLandmarkType.leftElbow, leftPaint);
      drawLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftShoulder, leftPaint);
      drawLine(PoseLandmarkType.rightWrist, PoseLandmarkType.rightElbow, rightPaint);
      drawLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightShoulder, rightPaint);

      // Body
      drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
      drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, rightPaint);
      drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, leftPaint);

      // Legs
      drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      drawLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, leftPaint);
      drawLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
      drawLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, rightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
