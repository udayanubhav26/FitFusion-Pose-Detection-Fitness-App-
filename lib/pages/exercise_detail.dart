import 'dart:async';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseDetailPage extends StatefulWidget {
  final String name;
  final String category;
  final String image;
  final String time; // Format: mm:ss

  const ExerciseDetailPage({
    super.key,
    required this.name,
    required this.category,
    required this.image,
    required this.time,
  });

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  bool isRunning = false;
  int secondsLeft = 0;
  int secondsSpent = 0;
  late int totalSeconds;
  Timer? timer;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    totalSeconds = _parseTime(widget.time);
    secondsLeft = totalSeconds;

    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    _startTimer();
  }

  int _parseTime(String time) {
    final parts = time.split(':');
    final minutes = int.tryParse(parts[0]) ?? 0;
    final seconds = int.tryParse(parts[1]) ?? 0;
    return minutes * 60 + seconds;
  }

  void _startTimer() {
    setState(() => isRunning = true);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft > 0) {
        setState(() {
          secondsLeft--;
          secondsSpent++;
        });
      } else {
        t.cancel();
        setState(() => isRunning = false);
        _confettiController.play();
        _markExerciseCompleted();
      }
    });
  }

  void _toggleTimer() {
    if (isRunning) {
      timer?.cancel();
      setState(() => isRunning = false);
    } else {
      _startTimer();
    }
  }

  void _resetTimer() {
    timer?.cancel();
    setState(() {
      secondsLeft = totalSeconds;
      secondsSpent = 0;
      isRunning = false;
    });
  }

  Future<void> _markExerciseCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    int finished = prefs.getInt('finishedWorkouts') ?? 0;
    int totalTime = prefs.getInt('timeSpent') ?? 0;

    await prefs.setInt('finishedWorkouts', finished + 1);
    await prefs.setInt('timeSpent', totalTime + secondsSpent);
  }

  @override
  void dispose() {
    // If user leaves early, still count time spent as in-progress
    if (secondsSpent > 0 && secondsLeft > 0) {
      _saveInProgress();
    }
    timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _saveInProgress() async {
    final prefs = await SharedPreferences.getInstance();
    int totalTime = prefs.getInt('timeSpent') ?? 0;
    await prefs.setInt('timeSpent', totalTime + secondsSpent);

    List<String> inProgress = prefs.getStringList('inProgressExercises') ?? [];
    if (!inProgress.contains(widget.name)) {
      inProgress.add(widget.name);
      await prefs.setStringList('inProgressExercises', inProgress);
    }
  }

  String getExerciseDetail(String name) {
    switch (name.toLowerCase()) {
      case 'neck stretch':
        return "Relieves tension and improves flexibility in the neck and upper back.";
      case 'push ups':
        return "Strengthens chest, triceps, and shoulders for upper-body power.";
      default:
        return "Focus on slow breathing and controlled movement.";
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = secondsLeft / totalSeconds;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(widget.image),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              widget.name,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.category.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              getExerciseDetail(widget.name),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 8,
                                    backgroundColor: Colors.orange.shade100,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isRunning
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_fill,
                                    color: Colors.deepOrange,
                                    size: 50,
                                  ),
                                  onPressed: _toggleTimer,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "${(secondsLeft ~/ 60).toString().padLeft(2, '0')}:${(secondsLeft % 60).toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              isRunning ? "In Progress" : "Workout Timer",
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _resetTimer,
                          icon: const Icon(Icons.refresh),
                          label: const Text("RESET"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 60, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.orange,
                Colors.purple
              ],
              gravity: 0.3,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
            ),
          ],
        ),
      ),
    );
  }
}
