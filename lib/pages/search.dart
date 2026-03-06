import 'package:flutter/material.dart';
import 'exercise_detail.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    // 🔹 All exercises divided by category
    final Map<String, List<Map<String, String>>> sections = {
      "STRETCHING": [
        {
          "name": "Neck Stretch",
          "sets": "2",
          "reps": "15",
          "time": "02:00",
          "image": "images/search/new.jpeg" 
        },
        {
          "name": "Shoulder Stretch",
          "sets": "2",
          "reps": "20",
          "time": "03:00",
          "image": "images/search/img2.jpeg"
        },
        {
          "name": "Hamstring Stretch",
          "sets": "2",
          "reps": "20",
          "time": "04:00",
          "image": "images/search/img1.jpeg"
        },
        {
          "name": "Quad Stretch",
          "sets": "2",
          "reps": "20",
          "time": "03:30",
          "image": "images/search/img4.jpeg"
        },
        {
          "name": "Back Stretch",
          "sets": "2",
          "reps": "20",
          "time": "04:00",
          "image": "images/search/img3.jpeg"
        },
      ],
      "CARDIO": [
        {
          "name": "Jumping Jacks",
          "sets": "3",
          "reps": "30",
          "time": "05:00",
          "image": "images/search/pho4.jpeg"
        },
        {
          "name": "Mountain Climbers",
          "sets": "3",
          "reps": "20",
          "time": "04:00",
          "image": "images/search/pho1.jpeg"
        },
        {
          "name": "Burpees",
          "sets": "3",
          "reps": "15",
          "time": "03:30",
          "image": "images/search/burp.jpeg"
        },
        {
          "name": "High Knees",
          "sets": "3",
          "reps": "25",
          "time": "04:00",
          "image": "images/search/pho2.jpeg"
        },
        {
          "name": "Butt Kicks",
          "sets": "3",
          "reps": "25",
          "time": "03:00",
          "image": "images/search/pho3.jpeg"
        },
      ],
      "YOGA": [
        {
          "name": "Tree Pose",
          "sets": "2",
          "reps": "5",
          "time": "05:00",
          "image": "images/search/trees.jpg"
        },
        {
          "name": "Cobra Pose",
          "sets": "2",
          "reps": "8",
          "time": "04:30",
          "image": "images/search/tas1.jpeg"
        },
        {
          "name": "Child’s Pose",
          "sets": "2",
          "reps": "5",
          "time": "03:00",
          "image": "images/search/tri3.jpeg"
        },
        {
          "name": "Warrior Pose",
          "sets": "2",
          "reps": "8",
          "time": "04:00",
          "image": "images/search/tas2.jpeg"
        },
        {
          "name": "Bridge Pose",
          "sets": "2",
          "reps": "8",
          "time": "03:30",
          "image": "images/search/bridge.png"
        },
      ],
      "ARMS": [
        {
          "name": "Push Ups",
          "sets": "3",
          "reps": "15",
          "time": "05:00",
          "image": "images/push.png"
        },
        {
          "name": "Tricep Dips",
          "sets": "3",
          "reps": "15",
          "time": "04:00",
          "image": "images/search/triceps.jpeg"
        },
        {
          "name": "Bicep Curls",
          "sets": "3",
          "reps": "12",
          "time": "04:00",
          "image": "images/search/curls.jpeg"
        },
        {
          "name": "Arm Circles",
          "sets": "2",
          "reps": "30",
          "time": "03:30",
          "image": "images/search/new.jpeg"
        },
        {
          "name": "Plank Shoulder Taps",
          "sets": "3",
          "reps": "20",
          "time": "04:30",
          "image": "images/search/plank.jpeg"
        },
      ],
    };

    // 🔍 Combine all exercises for search
    final allExercises = sections.entries
        .expand((section) => section.value
            .map((ex) => {...ex, "category": section.key}))
        .toList();

    // 🔎 Filter by search query
    final filteredExercises = allExercises
        .where((ex) => ex["name"]!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "ALL EXERCISES",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔎 Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search exercise...',
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // 🏋️ Exercise List
            Expanded(
              child: ListView(
                children: (query.isEmpty
                        ? sections.entries
                        : {"RESULTS": filteredExercises}.entries)
                    .map((section) {
                  final category = section.key;
                  final exercises = section.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Column(
                        children: exercises.map((ex) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 70,
                                  height: 60,
                                  child: Image.asset(
                                    ex["image"]!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.image_outlined,
                                          color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                ex["name"]!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                "${ex["sets"]} sets | ${ex["reps"]} Repetition",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.timer,
                                      color: Colors.deepPurple, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    ex["time"]!,
                                    style: const TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ExerciseDetailPage(
                                      name: ex["name"]!,
                                      category: ex["category"] ?? category,
                                      image: ex["image"]!,
                                      time: ex["time"]!,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 25),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
