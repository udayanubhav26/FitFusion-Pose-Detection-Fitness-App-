import 'package:flutter/material.dart';
import 'package:ui/pages/DetectionScreen.dart';
import 'package:ui/Model/ExerciseDataModel.dart';

class ExerciselistingScreen extends StatefulWidget {
  const ExerciselistingScreen({super.key});

  @override
  State<ExerciselistingScreen> createState() => _ExerciselistingScreenState();
}

class _ExerciselistingScreenState extends State<ExerciselistingScreen> {
  List<ExerciseDataModel> exerciseList = [];


  final List<Color> cardColors = [
    Color(0xFFFFCDD2), 
    Color(0xFFBBDEFB), 
    Color(0xFFC8E6C9), 
    Color(0xFFFFF9C4), 
    Color(0xFFE1BEE7), 
  ];

  void addData() {
    exerciseList.add(
        ExerciseDataModel("Push Ups", "pushup.gif", 0, cardColors[0], 1));
    exerciseList.add(
        ExerciseDataModel("Squats", "squat.gif", 0, cardColors[1], 2));
    exerciseList.add(
        ExerciseDataModel("Plank", "plank.gif", 0, cardColors[2], 3));
    exerciseList.add(
        ExerciseDataModel("Jumping Jack", "jumping.gif", 0, cardColors[3], 4));

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    addData();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: const Text(
          'AI Workout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? Colors.black : const Color(0xff005F9C),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: ListView.builder(
          itemCount: exerciseList.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        DetectionScreen(exerciseList[index])));
              },
              child: Container(
                height: 150,
                margin: const EdgeInsets.only(left: 15, right: 15, top: 20),
                decoration: BoxDecoration(
                  color: exerciseList[index].color,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          exerciseList[index].title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Image.asset(
                          'assets/${exerciseList[index].image}',
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
