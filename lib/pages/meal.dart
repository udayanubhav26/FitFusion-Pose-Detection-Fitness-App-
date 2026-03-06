import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealPage extends StatefulWidget {
  const MealPage({super.key});

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  List<Map<String, dynamic>> meals = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _calController = TextEditingController();

  int dailyGoal = 2500; // calorie goal
  int totalCalories = 0;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  // ---------------- Load Meals ----------------
  Future<void> _loadMeals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('mealHistory');

    if (data != null) {
      try {
        List decoded = jsonDecode(data);
        meals = List<Map<String, dynamic>>.from(decoded);
      } catch (e) {
        meals = [];
      }
    }

    _calculateTotal();
    setState(() {});
  }

  // ---------------- Save Meals ----------------
  Future<void> _saveMeals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mealHistory', jsonEncode(meals));
  }

  // ---------------- Calculate Total Calories ----------------
  void _calculateTotal() {
    totalCalories = meals.fold(
      0,
      (sum, item) => sum + (int.tryParse(item['cal'].toString()) ?? 0),
    );
  }

  // ---------------- Add Meal ----------------
  void _addMeal() {
    String name = _nameController.text.trim();
    int cal = int.tryParse(_calController.text.trim()) ?? 0;

    if (name.isEmpty || cal <= 0) return;

    setState(() {
      meals.add({
        'name': name,
        'cal': cal,
        'time': DateTime.now().toString(),
      });
      _calculateTotal();
    });

    _saveMeals();
    _nameController.clear();
    _calController.clear();
  }

  // ---------------- Progress % ----------------
  double _progress() => (totalCalories / dailyGoal).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meal Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ---------------- Donut Progress Circle ----------------
            Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(180, 180),
                      painter: DonutPainter(_progress(), Colors.green),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$totalCalories cal",
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "of $dailyGoal cal",
                          style: const TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ---------------- Input Fields ----------------
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Meal Name',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _calController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Calories',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green, size: 36),
                  onPressed: _addMeal,
                )
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              "Today's Meals",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // ---------------- Meal History ----------------
            meals.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text("No meals logged yet"),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: meals.length,
                    itemBuilder: (context, index) {
                      final meal = meals[index];
                      return Card(
                        color: Colors.green[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.restaurant, color: Colors.green, size: 32),
                          title: Text(meal['name']),
                          subtitle: Text(meal['time']),
                          trailing: Text("${meal['cal']} cal"),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Donut Painter ----------------
class DonutPainter extends CustomPainter {
  final double progress;
  final Color color;

  DonutPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    double stroke = 18;
    double radius = size.width / 2;

    var bgPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, color.withOpacity(0.5)],
      ).createShader(Rect.fromCircle(center: Offset(radius, radius), radius: radius))
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(radius, radius), radius, bgPaint);

    double sweep = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(radius, radius), radius: radius),
      -pi / 2,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
