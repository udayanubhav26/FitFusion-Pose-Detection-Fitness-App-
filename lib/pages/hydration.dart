import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class HydrationPage extends StatefulWidget {
  const HydrationPage({super.key});

  @override
  State<HydrationPage> createState() => _HydrationPageState();
}

class _HydrationPageState extends State<HydrationPage>
    with SingleTickerProviderStateMixin {

  List<Map<String, dynamic>> drinks = [];
  final TextEditingController _mlController = TextEditingController();

  int dailyGoal = 3000; // 3 Litres
  int totalDrank = 0;

  @override
  void initState() {
    super.initState();
    _loadDrinks();
  }

  Future<void> _loadDrinks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('hydrationHistory');

    if (data != null) {
      List decoded = jsonDecode(data);
      drinks = List<Map<String, dynamic>>.from(decoded);
    }

    _calculateTotal();
    setState(() {});
  }

  Future<void> _saveDrinks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('hydrationHistory', jsonEncode(drinks));
  }

  void _calculateTotal() {
   totalDrank = drinks.fold(0, (sum, item) => sum + (item['ml'] as int));
  }

  void _addDrink(int ml) {
    if (ml <= 0) return;

    setState(() {
      drinks.add({'ml': ml, 'time': DateTime.now().toString()});
      _calculateTotal();
    });

    _saveDrinks();
    _mlController.clear();
  }

  double _progress() => (totalDrank / dailyGoal).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hydration Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlue,
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
                      painter: DonutPainter(_progress()),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$totalDrank ml",
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "of $dailyGoal ml",
                          style: const TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ---------------- Quick Add Buttons ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _quickButton("250 ml", 250),
                _quickButton("500 ml", 500),
                _quickButton("1 L", 1000),
              ],
            ),

            const SizedBox(height: 15),

            // ---------------- Custom Input ----------------
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mlController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter custom ml',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    int ml = int.tryParse(_mlController.text.trim()) ?? 0;
                    _addDrink(ml);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: const Text(
                    "Add",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Today's Log",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // ---------------- Hydration History ----------------
            drinks.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text("No drinks logged today"),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: drinks.length,
                    itemBuilder: (context, index) {
                      final drink = drinks[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.local_drink, color: Colors.blue, size: 32),
                          title: Text("${drink['ml']} ml"),
                          subtitle: Text(drink['time']),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  // ---------------- Quick Button Widget ----------------
  Widget _quickButton(String label, int ml) {
    return ElevatedButton(
      onPressed: () => _addDrink(ml),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}

// ---------------- Donut Painter ----------------
class DonutPainter extends CustomPainter {
  final double progress;

  DonutPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    double stroke = 18;
    double radius = size.width / 2;

    var backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.blue, Colors.lightBlueAccent],
      ).createShader(Rect.fromCircle(center: Offset(radius, radius), radius: radius))
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(radius, radius), radius, backgroundPaint);

    double sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(radius, radius), radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
