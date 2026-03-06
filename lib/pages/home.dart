import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui/services/support_widget.dart';

class Home extends StatefulWidget {
  final String userName;

  const Home({super.key, required this.userName});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final double cardWidth = 300;

  List<bool> _horizontalVisible1 = [false, false, false, false];
  List<bool> _horizontalVisible2 = [false, false, false, false];
  List<bool> _topWorkoutVisible = [false, false, false];

  String? profileImageUrl;

  // Workout tracking
  int finishedWorkouts = 0;
  int totalTimeSpent = 0; // in seconds
  List<String> inProgressExercises = [];

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadWorkoutData();
    _animateCards();
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profileImageUrl = prefs.getString('userProfileImage');
    });
  }

  Future<void> _loadWorkoutData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      finishedWorkouts = prefs.getInt('finishedWorkouts') ?? 0;
      totalTimeSpent = prefs.getInt('timeSpent') ?? 0;
      inProgressExercises = prefs.getStringList('inProgressExercises') ?? [];
    });
  }

  void _animateCards() {
    for (int i = 0; i < _horizontalVisible1.length; i++) {
      Future.delayed(Duration(milliseconds: 300 * i), () {
        if (mounted) setState(() => _horizontalVisible1[i] = true);
      });
    }

    for (int i = 0; i < _horizontalVisible2.length; i++) {
      Future.delayed(Duration(milliseconds: 300 * i + 1500), () {
        if (mounted) setState(() => _horizontalVisible2[i] = true);
      });
    }

    for (int i = 0; i < _topWorkoutVisible.length; i++) {
      Future.delayed(Duration(milliseconds: 300 * i + 3000), () {
        if (mounted) setState(() => _topWorkoutVisible[i] = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ALWAYS LIGHT

      body: Padding(
        padding: const EdgeInsets.all(20.0),

        child: SingleChildScrollView(
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.black),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Greeting Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi ${widget.userName}",
                          style: AppWidget.healineTextstyle(24.0).copyWith(
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Welcome Back 👋",
                          style: AppWidget.healineTextstyle(18.0).copyWith(
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    // Profile Image
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: profileImageUrl != null &&
                                profileImageUrl!.isNotEmpty
                            ? Image.network(
                                profileImageUrl!,
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                "assets/Images/pushup.png",
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20.0),

                /// Workout Cards Row
                Row(
                  children: [
                    Material(
                      elevation: 6.0,
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text("💪 Finished",
                                style: AppWidget.healineTextstyle(18.0)
                                    .copyWith(color: Colors.black)),
                            const SizedBox(height: 20.0),
                            Text(
                              "$finishedWorkouts",
                              style: AppWidget.healineTextstyle(50.0)
                                  .copyWith(color: Colors.black),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              "Completed\nWorkouts",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10.0),

                    Column(
                      children: [
                        _miniStatCard(
                            "🔀 In Progress",
                            "${inProgressExercises.length}",
                            "Exercises"),
                        const SizedBox(height: 10.0),
                        _miniStatCard("⌚ Time Spend",
                            "${(totalTimeSpent ~/ 60)}", "Minutes"),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30.0),

                Center(
                  child: Text(
                    "Discover New Workouts",
                    style: AppWidget.healineTextstyle(20.0)
                        .copyWith(color: Colors.black),
                  ),
                ),

                const SizedBox(height: 20.0),

                _horizontalCardList(_horizontalVisible1, [
                  {
                    "title": "Cardio",
                    "exercises": "10 Exercises",
                    "duration": "5 Minutes",
                    "color": const Color(0xfffcb74f),
                    "image": "images/running.png"
                  },
                  {
                    "title": "Arms",
                    "exercises": "6 Exercises",
                    "duration": "3 Minutes",
                    "color": const Color(0xff57949e),
                    "image": "images/pushups.png"
                  },
                  {
                    "title": "Streching",
                    "exercises": "11 Exercises",
                    "duration": "2 Minutes",
                    "color": Colors.yellow,
                    "image": "images/streching.png"
                  },
                  {
                    "title": "Yoga",
                    "exercises": "5 Exercises",
                    "duration": "4 Minutes",
                    "color": Color.fromARGB(255, 165, 41, 138),
                    "image": "images/yoga.png"
                  },
                ]),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    "Discover New Exercises",
                    style: AppWidget.healineTextstyle(20.0)
                        .copyWith(color: Colors.black),
                  ),
                ),

                const SizedBox(height: 20),

                _horizontalCardList(_horizontalVisible2, [
                  {
                    "title": "Core/Abs",
                    "exercises": "30 Exercises",
                    "duration": "5 Minutes",
                    "color": Color.fromARGB(255, 252, 53, 3),
                    "image": "images/core.png"
                  },
                  {
                    "title": "Back",
                    "exercises": "20 Exercises",
                    "duration": "3 Minutes",
                    "color": Color.fromARGB(255, 54, 8, 82),
                    "image": "images/back.png"
                  },
                  {
                    "title": "Legs",
                    "exercises": "10 Exercises",
                    "duration": "4 Minutes",
                    "color": Color.fromARGB(255, 25, 119, 13),
                    "image": "images/leg.png"
                  },
                  {
                    "title": "Shoulders",
                    "exercises": "3 Exercises",
                    "duration": "40 Minutes",
                    "color": Color.fromARGB(255, 82, 75, 35),
                    "image": "images/shoulders.png"
                  },
                ]),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    "Top Workouts",
                    style: AppWidget.healineTextstyle(24.0)
                        .copyWith(color: Colors.black),
                  ),
                ),

                const SizedBox(height: 20),

                Column(
                  children: List.generate(3, (index) {
                    List<Map<String, dynamic>> topData = [
                      {
                        "title": "Squads",
                        "sets": "2 Sets",
                        "reps": "10 Repetitions",
                        "time": "2:00",
                        "image": "images/squads.png"
                      },
                      {
                        "title": "Pushups",
                        "sets": "5 Sets",
                        "reps": "10 Repetitions",
                        "time": "3:00",
                        "image": "images/push.png"
                      },
                      {
                        "title": "Biceps Curls",
                        "sets": "3 Sets",
                        "reps": "20 Repetitions",
                        "time": "3:00",
                        "image": "images/curls.png"
                      },
                    ];

                    return AnimatedOpacity(
                      duration: Duration(milliseconds: 500),
                      opacity: _topWorkoutVisible[index] ? 1 : 0,
                      child: AnimatedSlide(
                        duration: Duration(milliseconds: 500),
                        offset: _topWorkoutVisible[index]
                            ? Offset(0, 0)
                            : Offset(0, 0.3),
                        child: topWorkoutCard(
                          topData[index]["title"],
                          topData[index]["sets"],
                          topData[index]["reps"],
                          topData[index]["time"],
                          topData[index]["image"],
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Mini stat card
  Widget _miniStatCard(String title, String number, String label) {
    return Material(
      elevation: 6.0,
      borderRadius: BorderRadius.circular(20.0),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(title,
                style:
                    AppWidget.healineTextstyle(18.0).copyWith(color: Colors.black)),
            Row(
              children: [
                Text(
                  number,
                  style: AppWidget.healineTextstyle(24.0)
                      .copyWith(color: Colors.black),
                ),
                const SizedBox(width: 10.0),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Horizontal card list
  Widget _horizontalCardList(
      List<bool> visibilityList, List<Map<String, dynamic>> dataList) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dataList.length,
        itemBuilder: (context, index) {
          final data = dataList[index];
          return AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            opacity: visibilityList[index] ? 1 : 0,
            child: AnimatedSlide(
              duration: Duration(milliseconds: 500),
              offset: visibilityList[index]
                  ? Offset(0, 0)
                  : Offset(0, 0.3),
              child: workoutCard(
                data["title"],
                data["exercises"],
                data["duration"],
                data["color"],
                data["image"],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Horizontal workout card
  Widget workoutCard(
      String title, String exercises, String duration, Color color, String imagePath) {
    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 20),
      child: Material(
        elevation: 6.0,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppWidget.whiteboldTextstyle(28.0)),
                    Text(
                      exercises,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(imagePath),
            ],
          ),
        ),
      ),
    );
  }

  /// Top Workout Card
  Widget topWorkoutCard(
      String title, String sets, String reps, String time, String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppWidget.mediumTextstyle(22.0)
                          .copyWith(color: Colors.black),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      sets,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      reps,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(5),
                      width: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xffebeafb),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.alarm,
                              color: Color(0xff6358e1), size: 24),
                          const SizedBox(width: 5),
                          Text(
                            time,
                            style: const TextStyle(
                              color: Color(0xff6358e1),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20.0),
              Image.asset(imagePath, height: 100, width: 100),
            ],
          ),
        ),
      ),
    );
  }
}
