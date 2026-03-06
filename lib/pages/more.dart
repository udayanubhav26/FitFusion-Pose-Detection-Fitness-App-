import 'package:flutter/material.dart';
import 'chat_page.dart';           // AI Trainer
import 'hydration.dart';          // Hydration Tracker
import 'meal.dart';               // Meal Tracker
import 'weight.dart';             // Weight Counter Page
import 'progress.dart';           // Progress Chart Page

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {

  void _showInfoDialog(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title, style: const TextStyle(color: Colors.black)),
        content: Text(description, style: const TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.black87)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text(
          "More Features",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 4,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _buildFeatureCard(
                icon: Icons.smart_toy,
                iconColor: Colors.orangeAccent,
                title: "AI Trainer",
                subtitle: "Get personalized fitness tips",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage())),
                onInfoTap: () => _showInfoDialog(
                  context,
                  "AI Trainer",
                  "The AI Trainer gives personalized fitness advice and progress tracking.",
                ),
              ),
              const SizedBox(height: 16),

              _buildFeatureCard(
                icon: Icons.local_drink,
                iconColor: Colors.lightBlue,
                title: "Hydration Tracker",
                subtitle: "Keep track of your water intake",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HydrationPage())),
                onInfoTap: () => _showInfoDialog(
                  context,
                  "Hydration Tracker",
                  "Track your daily water intake to stay hydrated.",
                ),
              ),
              const SizedBox(height: 16),

              _buildFeatureCard(
                icon: Icons.restaurant_menu,
                iconColor: Colors.green,
                title: "Meal Tracker",
                subtitle: "Log your meals and calories",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MealPage())),
                onInfoTap: () => _showInfoDialog(
                  context,
                  "Meal Tracker",
                  "Log meals and calories to reach your fitness goals.",
                ),
              ),
              const SizedBox(height: 16),

              _buildFeatureCard(
                icon: Icons.monitor_weight,
                iconColor: Colors.purple,
                title: "Weight Counter",
                subtitle: "Track your weight progress",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeightCounterPage())),
                onInfoTap: () => _showInfoDialog(
                  context,
                  "Weight Counter",
                  "Log your weight changes over time.",
                ),
              ),
              const SizedBox(height: 16),

              _buildFeatureCard(
                icon: Icons.show_chart,
                iconColor: Colors.amber,
                title: "Progress Tracker",
                subtitle: "Monitor completed exercises",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressChartPage())),
                onInfoTap: () => _showInfoDialog(
                  context,
                  "Progress Tracker",
                  "Track completed workouts and progress history.",
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required VoidCallback onInfoTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            width: double.infinity,
            height: 120,
            child: ListTile(
              leading: Icon(icon, size: 50, color: iconColor),
              title: Text(
                title,
                style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                subtitle,
                style: const TextStyle(color: Colors.black54),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.black),
                onPressed: onInfoTap,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
